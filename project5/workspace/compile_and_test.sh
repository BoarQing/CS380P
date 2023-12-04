rm build/ -rf
clang-format -i *.cpp
clang-format -i *.hpp
mkdir -p ../output
cmake  -S . -B build/
cmake --build build/

./build/nbody_naive -i ../input/nb-10.txt -o ../output/nb_naive-10.txt -s 1000 -t 0 -d 0.005
./build/nbody_barnehut -i ../input/nb-10.txt -o ../output/nb_barnehut-10.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_barnehut-10.txt
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-1.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_mpi-10-1.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-2.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_mpi-10-2.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-4.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_mpi-10-4.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-9.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_mpi-10-9.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-16.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10.txt ../output/nb_mpi-10-16.txt

./build/nbody_naive -i ../input/nb-100.txt -o ../output/nb_naive-100.txt -s 1000 -t 0 -d 0.005
./build/nbody_barnehut -i ../input/nb-100.txt -o ../output/nb_barnehut-100.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_barnehut-100.txt
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-1.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_mpi-100-1.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-2.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_mpi-100-2.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-4.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_mpi-100-4.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-9.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_mpi-100-9.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-16.txt -s 1000 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-100.txt ../output/nb_mpi-100-16.txt

./build/nbody_naive -i ../input/nb-1000.txt -o ../output/nb_naive-1000.txt -s 100 -t 0 -d 0.005
./build/nbody_barnehut -i ../input/nb-1000.txt -o ../output/nb_barnehut-1000.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_barnehut-1000.txt
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-1.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_mpi-1000-1.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-2.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_mpi-1000-2.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-4.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_mpi-1000-4.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-9.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_mpi-1000-9.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-16.txt -s 100 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-1000.txt ../output/nb_mpi-1000-16.txt

./build/nbody_naive -i ../input/nb-10000.txt -o ../output/nb_naive-10000.txt -s 10 -t 0 -d 0.005
./build/nbody_barnehut -i ../input/nb-10000.txt -o ../output/nb_barnehut-10000.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_barnehut-10000.txt
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-1.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_mpi-10000-1.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-2.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_mpi-10000-2.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-4.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_mpi-10000-4.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-9.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_mpi-10000-9.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-16.txt -s 10 -t 0 -d 0.005
python3 cmp.py ../output/nb_naive-10000.txt ../output/nb_mpi-10000-16.txt

./build/nbody_barnehut -i ../input/nb-10.txt -o ../output/nb_barnehut-10-0.5.txt -s 1000 -d 0.005 -t 0.5
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-1-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10-0.5.txt ../output/nb_mpi-10-1-0.5.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-2-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10-0.5.txt ../output/nb_mpi-10-2-0.5.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-4-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10-0.5.txt ../output/nb_mpi-10-4-0.5.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-9-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10-0.5.txt ../output/nb_mpi-10-9-0.5.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-10.txt -o ../output/nb_mpi-10-16-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10-0.5.txt ../output/nb_mpi-10-16-0.5.txt

./build/nbody_barnehut -i ../input/nb-100.txt -o ../output/nb_barnehut-100-0.5.txt -s 1000 -d 0.005 -t 0.5
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-1-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-100-0.5.txt ../output/nb_mpi-100-1-0.5.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-2-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-100-0.5.txt ../output/nb_mpi-100-2-0.5.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-4-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-100-0.5.txt ../output/nb_mpi-100-4-0.5.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-9-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-100-0.5.txt ../output/nb_mpi-100-9-0.5.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-100.txt -o ../output/nb_mpi-100-16-0.5.txt -s 1000 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-100-0.5.txt ../output/nb_mpi-100-16-0.5.txt

./build/nbody_barnehut -i ../input/nb-1000.txt -o ../output/nb_barnehut-1000-0.5.txt -s 100 -d 0.005 -t 0.5
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-1-0.5.txt -s 100 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-1000-0.5.txt ../output/nb_mpi-1000-1-0.5.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-2-0.5.txt -s 100 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-1000-0.5.txt ../output/nb_mpi-1000-2-0.5.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-4-0.5.txt -s 100 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-1000-0.5.txt ../output/nb_mpi-1000-4-0.5.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-9-0.5.txt -s 100 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-1000-0.5.txt ../output/nb_mpi-1000-9-0.5.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-1000.txt -o ../output/nb_mpi-1000-16-0.5.txt -s 100 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-1000-0.5.txt ../output/nb_mpi-1000-16-0.5.txt

./build/nbody_barnehut -i ../input/nb-10000.txt -o ../output/nb_barnehut-10000-0.5.txt -s 10 -d 0.005 -t 0.5
mpirun -np 1 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-1-0.5.txt -s 10 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10000-0.5.txt ../output/nb_mpi-10000-1-0.5.txt
mpirun -np 2 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-2-0.5.txt -s 10 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10000-0.5.txt ../output/nb_mpi-10000-2-0.5.txt
mpirun -np 4 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-4-0.5.txt -s 10 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10000-0.5.txt ../output/nb_mpi-10000-4-0.5.txt
mpirun -np 9 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-9-0.5.txt -s 10 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10000-0.5.txt ../output/nb_mpi-10000-9-0.5.txt
mpirun -np 16 ./build/nbody_mpi -i ../input/nb-10000.txt -o ../output/nb_mpi-10000-16-0.5.txt -s 10 -d 0.005 -t 0.5
python3 cmp.py ../output/nb_barnehut-10000-0.5.txt ../output/nb_mpi-10000-16-0.5.txt