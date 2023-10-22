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

func ComputeHashGoroutine(tree_array *[]Tree, beg int, end int, wg *sync.WaitGroup, hash_map *map[int][]int) {
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
	AddHashToMap(hash_map, &all_result)
}

var g_lock sync.Mutex

func AddHashToMap(hash_map *map[int][]int, hash_result *[]HashResult) {
	g_lock.Lock()
	for _, result := range *hash_result {
		if _, ok := (*hash_map)[result.hash]; ok {
			(*hash_map)[result.hash] = append((*hash_map)[result.hash], result.id)
		} else {
			(*hash_map)[result.hash] = []int{result.id}
		}
	}
	g_lock.Unlock()
}

func ComputeHashGroup(tree_array *[]Tree, worker int) map[int][]int {
	var wg sync.WaitGroup
	ret := make(map[int][]int)
	count := len(*tree_array)
	work_load := count / worker
	extra_work_load := count - worker*work_load
	beg := 0
	for i := 0; i < worker; i++ {
		wg.Add(1)
		end := beg + work_load
		if i < extra_work_load {
			end += 1
		}
		go ComputeHashGoroutine(tree_array, beg, end, &wg, &ret)
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
func Compare(hash_group *map[int][]int, tree_array *[]Tree) [][]int {
	group_map := make(map[int][]int)
	for _, tree_id_array := range *hash_group {
		has_same := make([]bool, len(tree_id_array))
		for i := 0; i < len(tree_id_array); i++ {
			if has_same[i] {
				continue
			}
			id1 := tree_id_array[i]
			sorted_tree1 := GetSortedTree(&(*tree_array)[id1])
			for j := i + 1; j < len(tree_id_array); j++ {
				if has_same[j] {
					continue
				}
				id2 := tree_id_array[j]
				sorted_tree2 := GetSortedTree(&(*tree_array)[id2])
				is_same := CmpTree(&sorted_tree1, &sorted_tree2)
				if is_same {
					has_same[i] = true
					has_same[j] = true
					if _, ok := group_map[id1]; ok {
						group_map[id1] = append(group_map[id1], id2)
					} else {
						group_map[id1] = []int{id1, id2}
					}
				}
			}
		}
	}
	var ret [][]int
	for _, id_arr := range group_map {
		if len(id_arr) > 1 {
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
