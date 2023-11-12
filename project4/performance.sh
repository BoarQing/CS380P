cargo build --release
rm -f *.txt

for ((i=1; i<=32; i*=2)); do
    for ((j=1; j<=5; j++)); do
        each=$((128 / i))
        ./target/release/two_phase_commit -S 1 -s 0.95 -r $each -p 10 -c $i -m run &>> client_$i.txt
        sleep 0.5
    done
done

python3 graph_client.py

rm -f *.txt

for ((i=1; i<=32; i+=1)); do
    for ((j=1; j<=5; j++)); do
        each=32
        ./target/release/two_phase_commit -S 1 -s 0.95 -r 32 -p $i -c 4 -m run &>> parti_$i.txt
        sleep 0.5
    done
done

python3 graph_client.py

rm -f *.txt

for ((i=0; i<32; i+=1)); do
    for ((j=1; j<=5; j++)); do
        each=32
        p=$(echo "scale=18; $i * (1.0 / 31.0)" | bc)
        ./target/release/two_phase_commit -S $p -s 0.95 -r 32 -p 10 -c 4 -m run &>> fail_$p.txt
        sleep 0.5
    done
done

# python3 graph_fail.py