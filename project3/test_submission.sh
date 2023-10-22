echo "BST=1"
go run BST.go -input "input/simple.txt" -hash-workers=1 -data-workers=1 -comp-workers=1 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=1 -data-workers=1 -comp-workers=1 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=1 -data-workers=1 -comp-workers=1 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=2"
go run BST.go -input "input/simple.txt" -hash-workers=2 -data-workers=1 -comp-workers=2 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=2 -data-workers=1 -comp-workers=2 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=2 -data-workers=1 -comp-workers=2 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=2 -data-workers=2 -comp-workers=2 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=2 -data-workers=2 -comp-workers=2 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=2 -data-workers=2 -comp-workers=2 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=4"
go run BST.go -input "input/simple.txt" -hash-workers=4 -data-workers=1 -comp-workers=4 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=4 -data-workers=1 -comp-workers=4 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=4 -data-workers=1 -comp-workers=4 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=4 -data-workers=4 -comp-workers=4 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=4 -data-workers=4 -comp-workers=4 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=4 -data-workers=4 -comp-workers=4 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=8"
go run BST.go -input "input/simple.txt" -hash-workers=8 -data-workers=1 -comp-workers=8 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=8 -data-workers=1 -comp-workers=8 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=8 -data-workers=1 -comp-workers=8 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=8 -data-workers=8 -comp-workers=8 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=8 -data-workers=8 -comp-workers=8 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=8 -data-workers=8 -comp-workers=8 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=10"
go run BST.go -input "input/simple.txt" -hash-workers=10 -data-workers=1 -comp-workers=10 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=10 -data-workers=1 -comp-workers=10 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=10 -data-workers=1 -comp-workers=10 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=10 -data-workers=10 -comp-workers=10 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=10 -data-workers=10 -comp-workers=10 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=10 -data-workers=10 -comp-workers=10 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=16"
go run BST.go -input "input/simple.txt" -hash-workers=16 -data-workers=1 -comp-workers=16 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=16 -data-workers=1 -comp-workers=16 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=16 -data-workers=1 -comp-workers=16 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=16 -data-workers=16 -comp-workers=16 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=16 -data-workers=16 -comp-workers=16 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=16 -data-workers=16 -comp-workers=16 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=32"
go run BST.go -input "input/simple.txt" -hash-workers=32 -data-workers=1 -comp-workers=32 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=32 -data-workers=1 -comp-workers=32 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=32 -data-workers=1 -comp-workers=32 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/simple.txt" -hash-workers=32 -data-workers=32 -comp-workers=32 > result/BST_simple.txt
go run BST.go -input "input/fine.txt" -hash-workers=32 -data-workers=32 -comp-workers=32 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=32 -data-workers=32 -comp-workers=32 > result/BST_coarse.txt

python3 cmp.py result/BST_simple.txt golden/simple.txt
python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_simple.txt | grep Time
cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

echo "BST=MAX"
go run BST.go -input "input/fine.txt" -hash-workers=100000 -data-workers=1 -comp-workers=100000 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=100 -data-workers=1 -comp-workers=100 > result/BST_coarse.txt

python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time

go run BST.go -input "input/fine.txt" -hash-workers=100000 -data-workers=100000 -comp-workers=100000 > result/BST_fine.txt
go run BST.go -input "input/coarse.txt" -hash-workers=100 -data-workers=100 -comp-workers=100 > result/BST_coarse.txt

python3 cmp.py result/BST_fine.txt golden/fine.txt
python3 cmp.py result/BST_coarse.txt golden/coarse.txt

cat result/BST_fine.txt | grep Time
cat result/BST_coarse.txt | grep Time