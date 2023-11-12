cargo build

./target/debug/two_phase_commit -S 1.0 -s 1.0 -c 4 -p 10 -r 10 -m run
./target/debug/two_phase_commit -S 1.0 -s 1.0 -c 4 -p 10 -r 10 -m check

./target/debug/two_phase_commit -S 1.0 -s .95 -c 4 -p 10 -r 10 -m run
./target/debug/two_phase_commit -S 1.0 -s .95 -c 4 -p 10 -r 10 -m check

./target/debug/two_phase_commit -s .95 -S 1.0 -c 4 -p 10 -r 10 -m run
./target/debug/two_phase_commit -s .95 -S 1.0 -c 4 -p 10 -r 10 -m check

./target/debug/two_phase_commit -s .95 -S 0.95 -c 4 -p 10 -r 10 -m run
./target/debug/two_phase_commit -s .95 -S 0.95 -c 4 -p 10 -r 10 -m check