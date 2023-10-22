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

func CompWorker(tree_array *[]Tree, idx1 int, idx2 int, tree_idx1 int, tree_idx2 int, length int, result *[]bool, wg *sync.WaitGroup) {
	defer wg.Done()
	sorted_tree1 := GetSortedTree(&(*tree_array)[tree_idx1])
	sorted_tree2 := GetSortedTree(&(*tree_array)[tree_idx2])
	is_same := CmpTree(&sorted_tree1, &sorted_tree2)
	if is_same {
		(*result)[idx1*length+idx2] = is_same
	}
}

func Compare(hash_group *map[int][]int, tree_array *[]Tree) [][]int {
	var matrix [][]bool
	var hash_slice []int
	wg_slice := []*sync.WaitGroup{}
	for hash, tree_id_array := range *hash_group {
		length := len(tree_id_array)
		cur_group_map := make([]bool, length*length)
		matrix = append(matrix, cur_group_map)
		hash_slice = append(hash_slice, hash)
		wg := sync.WaitGroup{}
		wg_slice = append(wg_slice, &wg)
		for i := 0; i < length; i++ {
			tree_idx1 := tree_id_array[i]
			for j := i + 1; j < length; j++ {
				tree_idx2 := tree_id_array[j]
				wg.Add(1)
				go CompWorker(tree_array, i, j, tree_idx1, tree_idx2, length, &cur_group_map, &wg)
			}
		}
	}
	var ret [][]int

	for wait_idx := 0; wait_idx < len(wg_slice); wait_idx++ {
		wg_slice[wait_idx].Wait()
		hash := hash_slice[wait_idx]
		length := len((*hash_group)[hash])
		has_same := make([]bool, length)
		group_map := make(map[int][]int)
		for i := 0; i < length; i++ {
			if has_same[i] {
				continue
			}
			for j := i + 1; j < length; j++ {
				if has_same[j] {
					continue
				}
				if matrix[wait_idx][i*length+j] {
					has_same[i] = true
					has_same[j] = true
					if _, ok := group_map[i]; ok {
						group_map[i] = append(group_map[i], j)
					} else {
						group_map[i] = []int{i, j}
					}
				}
			}
		}
		for _, idx_arr := range group_map {
			if len(idx_arr) <= 1 {
				continue
			}
			var id_arr []int
			for i := 0; i < len(idx_arr); i++ {
				id_arr = append(id_arr, (*hash_group)[hash][idx_arr[i]])
			}
			ret = append(ret, id_arr)
		}
	}
	return ret
}

func PrintCmpGroup(cmp_group *[][]int) {
	for idx, id_arr := range *cmp_group {
		fmt.Printf("group %d:", idx)
		for _, id := range id_arr {
			fmt.Printf(" %d", id)
		}
		fmt.Println()
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
	group := Compare(&hash_group, &tree_array)
	compare_time := TOCK()

	fmt.Println("compareTreeTime:", compare_time)
	PrintCmpGroup(&group)
}
