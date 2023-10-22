package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Tree struct {
	id   int
	root *Node
}

type Node struct {
	value int
	left  *Node
	right *Node
}

type Argument struct {
	hash_worker int
	data_worker int
	comp_worker int
	input       string
}

type HashResult struct {
	hash int
	id   int
}

type CompJob struct {
	hash      int
	hash_idx1 int
	hash_idx2 int
	tree_idx1 int
	tree_idx2 int
}

type CompJobResult struct {
	job   *CompJob
	match bool
}

type ConcurrentBuffer struct {
	job       []*CompJob
	capacity  int
	front     int
	back      int
	mutex     sync.Mutex
	not_full  *sync.Cond
	not_empty *sync.Cond
}

type ResultBuffer struct {
	parent    []int
	group_map map[int]map[int]struct{}
	mutex     sync.Mutex
}

func GetResultBuffer(capacity int) *ResultBuffer {
	buffer := &ResultBuffer{
		group_map: make(map[int]map[int]struct{}),
		parent:    make([]int, capacity),
	}
	for i := 0; i < capacity; i++ {
		buffer.parent[i] = -1
	}
	return buffer
}

func GetBuffer(capacity int) *ConcurrentBuffer {
	buffer := &ConcurrentBuffer{
		job:      make([]*CompJob, capacity),
		capacity: capacity,
		front:    0,
		back:     0,
	}
	buffer.not_full = sync.NewCond(&buffer.mutex)
	buffer.not_empty = sync.NewCond(&buffer.mutex)
	return buffer
}

func GetJob(buffer *ConcurrentBuffer) *CompJob {
	buffer.mutex.Lock()
	defer buffer.mutex.Unlock()

	for buffer.front == buffer.back {
		buffer.not_empty.Wait()
	}

	ret := buffer.job[buffer.front]
	buffer.front = (buffer.front + 1) % buffer.capacity
	buffer.not_full.Signal()
	return ret
}

func AddJob(buffer *ConcurrentBuffer, job *CompJob) {
	buffer.mutex.Lock()
	defer buffer.mutex.Unlock()

	for (buffer.back+1)%buffer.capacity == buffer.front {
		buffer.not_full.Wait()
	}

	buffer.job[buffer.back] = job
	buffer.back = (buffer.back + 1) % buffer.capacity
	buffer.not_empty.Signal()
}

func MaxInt(a int, b int) int {
	if a > b {
		return a
	}
	return b
}

func PutJobResult(buffer *ResultBuffer, job *CompJobResult) {
	new_parent := MaxInt(job.job.tree_idx1, job.job.tree_idx2)
	buffer.mutex.Lock()
	defer buffer.mutex.Unlock()
	p1 := buffer.parent[job.job.tree_idx1]
	p2 := buffer.parent[job.job.tree_idx2]
	new_parent = MaxInt(new_parent, p1)
	new_parent = MaxInt(new_parent, p2)
	if _, ok := buffer.group_map[new_parent]; !ok {
		buffer.group_map[new_parent] = make(map[int]struct{})
	}
	buffer.group_map[new_parent][job.job.tree_idx1] = struct{}{}
	buffer.group_map[new_parent][job.job.tree_idx2] = struct{}{}

	if p1 != new_parent && p1 != -1 {
		for id, _ := range buffer.group_map[p1] {
			buffer.group_map[new_parent][id] = struct{}{}
			buffer.parent[id] = new_parent
		}
		delete(buffer.group_map, p1)
	}

	if p2 != new_parent && p2 != -1 {
		for id, _ := range buffer.group_map[p2] {
			buffer.group_map[new_parent][id] = struct{}{}
			buffer.parent[id] = new_parent
		}
		delete(buffer.group_map, p2)
	}

	buffer.parent[job.job.tree_idx1] = new_parent
	buffer.parent[job.job.tree_idx2] = new_parent
}

func IsChecked(buffer *ResultBuffer, idx int) bool {
	buffer.mutex.Lock()
	defer buffer.mutex.Unlock()
	return buffer.parent[idx] != -1
}

func InorderTraverseHash(node *Node, hash *int) {
	if node == nil {
		return
	}
	InorderTraverseHash(node.left, hash)
	val := node.value + 2
	*hash = (*hash*val + val) % 1000
	InorderTraverseHash(node.right, hash)
}

func ComputeHash(tree *Tree) int {
	hash := 1
	InorderTraverseHash(tree.root, &hash)
	return hash
}

func ParseArgu() Argument {
	var argu Argument

	hash_worker_ptr := flag.Int("hash-workers", 0, "The number of hash worker")
	data_worker_ptr := flag.Int("data-workers", 0, "The number of data worker")
	comp_worker_ptr := flag.Int("comp-workers", 0, "The number of comp worker")
	input_ptr := flag.String("input", "", "input file path")

	flag.Parse()

	argu.hash_worker = *hash_worker_ptr
	argu.data_worker = *data_worker_ptr
	argu.comp_worker = *comp_worker_ptr
	argu.input = *input_ptr
	return argu
}

func Insert(root *Node, node *Node) {
	if node.value <= root.value {
		if root.left == nil {
			root.left = node
		} else {
			Insert(root.left, node)
		}
	} else {
		if root.right == nil {
			root.right = node
		} else {
			Insert(root.right, node)
		}
	}
}
func AddValToTree(node *Tree, value int) {
	new_node := Node{
		value: value,
		left:  nil,
		right: nil,
	}
	if node.root == nil {
		node.root = &new_node
		return
	}
	Insert(node.root, &new_node)
}

func ReadBSTTree(input string) []Tree {
	content, err := ioutil.ReadFile(input)
	if err != nil {
		fmt.Println("Error reading the file:", err)
		return []Tree{}
	}
	fileContent := string(content)
	lines := strings.Split(fileContent, "\n")
	ret := []Tree{}
	for id, line := range lines {
		if len(line) == 0 {
			continue
		}
		str_numbers := strings.Split(line, " ")
		root := Tree{
			id:   id,
			root: nil,
		}
		for _, str := range str_numbers {
			val, _ := strconv.Atoi(str)
			AddValToTree(&root, val)
		}
		ret = append(ret, root)
	}
	return ret
}

func ComputeHashGoroutine(tree_array *[]Tree, beg int, end int, wg *sync.WaitGroup, hash_result chan *[]HashResult) {
	defer wg.Done()
	all_result := []HashResult{}
	for i := beg; i < end; i++ {
		hash := ComputeHash(&((*tree_array)[i]))
		result := HashResult{
			hash: hash,
			id:   (*tree_array)[i].id,
		}
		all_result = append(all_result, result)
	}
	hash_result <- &all_result
}

func AddHashGoroutine(hash_map *map[int][]int, count int, wg *sync.WaitGroup, hash_result chan *[]HashResult) {
	defer wg.Done()
	for i := 0; i < count; i++ {
		all_result := <-hash_result
		for _, result := range *all_result {
			if _, ok := (*hash_map)[result.hash]; ok {
				(*hash_map)[result.hash] = append((*hash_map)[result.hash], result.id)
			} else {
				(*hash_map)[result.hash] = []int{result.id}
			}
		}
	}
}

func ComputeHashGroup(tree_array *[]Tree, worker int) map[int][]int {
	hash_result := make(chan *[]HashResult, worker)
	var wg sync.WaitGroup
	count := len(*tree_array)
	work_load := count / worker
	extra_work_load := count - worker*work_load
	beg := 0

	wg.Add(1)
	ret := make(map[int][]int)
	go AddHashGoroutine(&ret, worker, &wg, hash_result)

	for i := 0; i < worker; i++ {
		wg.Add(1)
		end := beg + work_load
		if i < extra_work_load {
			end += 1
		}
		go ComputeHashGoroutine(tree_array, beg, end, &wg, hash_result)
		beg = end
	}
	wg.Wait()
	return ret
}

func PrintHashGroup(hash_group *map[int][]int) {
	for key, tree_id_array := range *hash_group {
		if len(tree_id_array) <= 1 {
			continue
		}
		fmt.Printf("%d:", key)
		for _, tree_id := range tree_id_array {
			fmt.Printf(" %d", tree_id)
		}
		fmt.Println()
	}
}

func InorderTraverse(node *Node, arr *[]int) {
	if node == nil {
		return
	}
	InorderTraverse(node.left, arr)
	*arr = append(*arr, node.value)
	InorderTraverse(node.right, arr)
}

func GetSortedTree(tree *Tree) []int {
	ret := []int{}
	InorderTraverse(tree.root, &ret)
	return ret
}

func CmpTree(tree1 *[]int, tree2 *[]int) bool {
	if len(*tree1) != len(*tree2) {
		return false
	}
	for i := 0; i < len(*tree1); i++ {
		if (*tree1)[i] != (*tree2)[i] {
			return false
		}
	}
	return true
}

func CompWorker(tree_array *[]Tree, buffer *ConcurrentBuffer, result_buffer *ResultBuffer, wg *sync.WaitGroup) {
	defer wg.Done()
	for {
		job := GetJob(buffer)
		if job.hash == -1 {
			return
		}
		sorted_tree1 := GetSortedTree(&(*tree_array)[job.tree_idx1])
		sorted_tree2 := GetSortedTree(&(*tree_array)[job.tree_idx2])
		is_same := CmpTree(&sorted_tree1, &sorted_tree2)
		result := CompJobResult{
			job:   job,
			match: is_same,
		}
		if is_same {
			PutJobResult(result_buffer, &result)
		}
	}
}

func Done(buffer *ConcurrentBuffer) {
	for i := 0; i < buffer.capacity; i++ {
		job := &CompJob{
			hash:      -1,
			hash_idx1: 0,
			hash_idx2: 0,
			tree_idx1: 0,
			tree_idx2: 0,
		}
		AddJob(buffer, job)
	}
}

func PlanWorker(hash_group *map[int][]int, tree_array *[]Tree, buffer *ConcurrentBuffer, result_buffer *ResultBuffer) {
	for hash, tree_id_array := range *hash_group {
		for i := 0; i < len(tree_id_array); i++ {
			tree_idx1 := tree_id_array[i]
			if IsChecked(result_buffer, tree_idx1) {
				continue
			}
			for j := i + 1; j < len(tree_id_array); j++ {
				tree_idx2 := tree_id_array[j]
				if IsChecked(result_buffer, tree_idx2) {
					continue
				}
				job := &CompJob{
					hash:      hash,
					hash_idx1: i,
					hash_idx2: j,
					tree_idx1: tree_idx1,
					tree_idx2: tree_idx2,
				}
				AddJob(buffer, job)
			}
		}
	}
	Done(buffer)
}

func Compare(hash_group *map[int][]int, tree_array *[]Tree, worker int) *map[int]map[int]struct{} {
	buffer := GetBuffer(worker)
	result_buffer := GetResultBuffer(len(*tree_array))
	var wg sync.WaitGroup
	go PlanWorker(hash_group, tree_array, buffer, result_buffer)
	for i := 0; i < worker; i++ {
		wg.Add(1)
		go CompWorker(tree_array, buffer, result_buffer, &wg)
	}
	wg.Wait()
	return &result_buffer.group_map
}

func PrintCmpGroup(cmp_group *map[int]map[int]struct{}) {
	idx := 0
	for _, id_set := range *cmp_group {
		fmt.Printf("group %d:", idx)
		for id, _ := range id_set {
			fmt.Printf(" %d", id)
		}
		fmt.Println()
		idx++
	}
}

var g_start_time time.Time

func TICK() {
	g_start_time = time.Now()
}

func TOCK() float64 {
	end_time := time.Now()
	elapsed_time := end_time.Sub(g_start_time)
	seconds := float64(elapsed_time) / float64(time.Second)
	return seconds
}

func main() {
	argu := ParseArgu()
	tree_array := ReadBSTTree(argu.input)

	TICK()
	hash_group := ComputeHashGroup(&tree_array, argu.hash_worker)
	hash_time := TOCK()

	fmt.Println("hashGroupTime:", hash_time)
	PrintHashGroup(&hash_group)

	TICK()
	group := Compare(&hash_group, &tree_array, argu.comp_worker)
	compare_time := TOCK()

	fmt.Println("compareTreeTime:", compare_time)
	PrintCmpGroup(group)
}
