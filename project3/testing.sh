mkdir -p golden
python3 check.py input/simple.txt > golden/simple.txt
python3 check.py input/fine.txt > golden/fine.txt
python3 check.py input/coarse.txt > golden/coarse.txt
mkdir -p result

gofmt -w bst_comparsion_seqnetial.go
gofmt -w bst_comparsion_step1_arg.go
gofmt -w bst_comparsion_step1_channel.go
gofmt -w bst_comparsion_step1_each_goroutine.go
gofmt -w bst_comparsion_step1_lock.go
gofmt -w bst_comparsion_step2_buffer.go
gofmt -w bst_comparsion_step2_matrix.go
go run bst_comparsion_seqnetial.go -input "input/simple.txt" > result/simple.txt
go run bst_comparsion_seqnetial.go -input "input/fine.txt" > result/fine.txt
go run bst_comparsion_seqnetial.go -input "input/coarse.txt" > result/coarse.txt

echo "sequential"
python3 cmp.py result/simple.txt golden/simple.txt
python3 cmp.py result/fine.txt golden/fine.txt
python3 cmp.py result/coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=1 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=1 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=1 > result/channel_coarse.txt

echo "channel=1"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=2 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=2 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=2 > result/channel_coarse.txt

echo "channel=2"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=3 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=3 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=3 > result/channel_coarse.txt

echo "channel=3"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=4 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=4 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=4 > result/channel_coarse.txt

echo "channel=4"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=8 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=8 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=8 > result/channel_coarse.txt

echo "channel=8"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/simple.txt" -hash-workers=10 > result/channel_simple.txt
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=10 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=10 > result/channel_coarse.txt

echo "channel=10"
python3 cmp.py result/channel_simple.txt golden/simple.txt
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=16 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=16 > result/channel_coarse.txt

echo "channel=16"
python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

echo "channel=max"
go run bst_comparsion_step1_channel.go -input "input/fine.txt" -hash-workers=100000 > result/channel_fine.txt
go run bst_comparsion_step1_channel.go -input "input/coarse.txt" -hash-workers=100 > result/channel_coarse.txt

python3 cmp.py result/channel_fine.txt golden/fine.txt
python3 cmp.py result/channel_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=1 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=1 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=1 > result/lock_coarse.txt

echo "lock=1"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=2 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=2 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=2 > result/lock_coarse.txt

echo "lock=2"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=3 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=3 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=3 > result/lock_coarse.txt

echo "lock=3"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=4 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=4 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=4 > result/lock_coarse.txt

echo "lock=4"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=8 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=8 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=8 > result/lock_coarse.txt

echo "lock=8"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/simple.txt" -hash-workers=10 > result/lock_simple.txt
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=10 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=10 > result/lock_coarse.txt

echo "lock=10"
python3 cmp.py result/lock_simple.txt golden/simple.txt
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=16 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=16 > result/lock_coarse.txt

echo "lock=16"
python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

echo "lock=max"
go run bst_comparsion_step1_lock.go -input "input/fine.txt" -hash-workers=100000 > result/lock_fine.txt
go run bst_comparsion_step1_lock.go -input "input/coarse.txt" -hash-workers=100 > result/lock_coarse.txt

python3 cmp.py result/lock_fine.txt golden/fine.txt
python3 cmp.py result/lock_coarse.txt golden/coarse.txt

echo "matrix"
go run bst_comparsion_step2_matrix.go -input "input/simple.txt" -hash-workers=8 > result/matrix_simple.txt
go run bst_comparsion_step2_matrix.go -input "input/fine.txt" -hash-workers=8 > result/matrix_fine.txt
go run bst_comparsion_step2_matrix.go -input "input/coarse.txt" -hash-workers=8 > result/matrix_coarse.txt

python3 cmp.py result/matrix_simple.txt golden/simple.txt
python3 cmp.py result/matrix_fine.txt golden/fine.txt
python3 cmp.py result/matrix_coarse.txt golden/coarse.txt

echo "buffer=2"
go run bst_comparsion_step2_buffer.go -input "input/simple.txt" -hash-workers=8 -comp-workers=2 > result/buffer_simple.txt
go run bst_comparsion_step2_buffer.go -input "input/fine.txt" -hash-workers=8 -comp-workers=2 > result/buffer_fine.txt
go run bst_comparsion_step2_buffer.go -input "input/coarse.txt" -hash-workers=8 -comp-workers=2 > result/buffer_coarse.txt

python3 cmp.py result/buffer_simple.txt golden/simple.txt
python3 cmp.py result/buffer_fine.txt golden/fine.txt
python3 cmp.py result/buffer_coarse.txt golden/coarse.txt

echo "buffer=4"
go run bst_comparsion_step2_buffer.go -input "input/simple.txt" -hash-workers=8 -comp-workers=4 > result/buffer_simple.txt
go run bst_comparsion_step2_buffer.go -input "input/fine.txt" -hash-workers=8 -comp-workers=4 > result/buffer_fine.txt
go run bst_comparsion_step2_buffer.go -input "input/coarse.txt" -hash-workers=8 -comp-workers=4 > result/buffer_coarse.txt

python3 cmp.py result/buffer_simple.txt golden/simple.txt
python3 cmp.py result/buffer_fine.txt golden/fine.txt
python3 cmp.py result/buffer_coarse.txt golden/coarse.txt

echo "buffer=8"
go run bst_comparsion_step2_buffer.go -input "input/simple.txt" -hash-workers=8 -comp-workers=8 > result/buffer_simple.txt
go run bst_comparsion_step2_buffer.go -input "input/fine.txt" -hash-workers=8 -comp-workers=8 > result/buffer_fine.txt
go run bst_comparsion_step2_buffer.go -input "input/coarse.txt" -hash-workers=8 -comp-workers=8 > result/buffer_coarse.txt

python3 cmp.py result/buffer_simple.txt golden/simple.txt
python3 cmp.py result/buffer_fine.txt golden/fine.txt
python3 cmp.py result/buffer_coarse.txt golden/coarse.txt

echo "buffer=10"
go run bst_comparsion_step2_buffer.go -input "input/simple.txt" -hash-workers=8 -comp-workers=10 > result/buffer_simple.txt
go run bst_comparsion_step2_buffer.go -input "input/fine.txt" -hash-workers=8 -comp-workers=10 > result/buffer_fine.txt
go run bst_comparsion_step2_buffer.go -input "input/coarse.txt" -hash-workers=8 -comp-workers=10 > result/buffer_coarse.txt

python3 cmp.py result/buffer_fine.txt golden/fine.txt
python3 cmp.py result/buffer_coarse.txt golden/coarse.txt

echo "buffer=MAX"
go run bst_comparsion_step2_buffer.go -input "input/fine.txt" -hash-workers=8 -comp-workers=100000 > result/buffer_fine.txt
go run bst_comparsion_step2_buffer.go -input "input/coarse.txt" -hash-workers=8 -comp-workers=100 > result/buffer_coarse.txt

python3 cmp.py result/buffer_fine.txt golden/fine.txt
python3 cmp.py result/buffer_coarse.txt golden/coarse.txt
