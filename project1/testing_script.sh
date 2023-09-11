make compile
echo -n " 0 " && bin/prefix_scan -i tests/16k.txt -n  0 -l 100000 -o bin/output_sequential_loop_100000.txt
echo -n " 1 " && bin/prefix_scan -i tests/16k.txt -n  1 -l 100000 -o bin/output_parallel_1_loop_100000.txt
echo -n " 2 " && bin/prefix_scan -i tests/16k.txt -n  2 -l 100000 -o bin/output_parallel_2_loop_100000.txt
echo -n " 3 " && bin/prefix_scan -i tests/16k.txt -n  3 -l 100000 -o bin/output_parallel_3_loop_100000.txt
echo -n " 4 " && bin/prefix_scan -i tests/16k.txt -n  4 -l 100000 -o bin/output_parallel_4_loop_100000.txt
echo -n " 5 " && bin/prefix_scan -i tests/16k.txt -n  5 -l 100000 -o bin/output_parallel_5_loop_100000.txt
echo -n " 6 " && bin/prefix_scan -i tests/16k.txt -n  6 -l 100000 -o bin/output_parallel_6_loop_100000.txt
echo -n " 7 " && bin/prefix_scan -i tests/16k.txt -n  7 -l 100000 -o bin/output_parallel_7_loop_100000.txt
echo -n " 8 " && bin/prefix_scan -i tests/16k.txt -n  8 -l 100000 -o bin/output_parallel_8_loop_100000.txt
echo -n " 9 " && bin/prefix_scan -i tests/16k.txt -n  9 -l 100000 -o bin/output_parallel_9_loop_100000.txt
echo -n "10 " && bin/prefix_scan -i tests/16k.txt -n 10 -l 100000 -o bin/output_parallel_10_loop_100000.txt
echo -n "11 " && bin/prefix_scan -i tests/16k.txt -n 11 -l 100000 -o bin/output_parallel_11_loop_100000.txt
echo -n "12 " && bin/prefix_scan -i tests/16k.txt -n 12 -l 100000 -o bin/output_parallel_12_loop_100000.txt
echo -n "13 " && bin/prefix_scan -i tests/16k.txt -n 13 -l 100000 -o bin/output_parallel_13_loop_100000.txt
echo -n "14 " && bin/prefix_scan -i tests/16k.txt -n 14 -l 100000 -o bin/output_parallel_14_loop_100000.txt
echo -n "15 " && bin/prefix_scan -i tests/16k.txt -n 15 -l 100000 -o bin/output_parallel_15_loop_100000.txt
echo -n "16 " && bin/prefix_scan -i tests/16k.txt -n 16 -l 100000 -o bin/output_parallel_16_loop_100000.txt
echo -n "17 " && bin/prefix_scan -i tests/16k.txt -n 17 -l 100000 -o bin/output_parallel_17_loop_100000.txt
echo -n "18 " && bin/prefix_scan -i tests/16k.txt -n 18 -l 100000 -o bin/output_parallel_18_loop_100000.txt
echo -n "19 " && bin/prefix_scan -i tests/16k.txt -n 19 -l 100000 -o bin/output_parallel_19_loop_100000.txt
echo -n "20 " && bin/prefix_scan -i tests/16k.txt -n 20 -l 100000 -o bin/output_parallel_20_loop_100000.txt
echo -n "21 " && bin/prefix_scan -i tests/16k.txt -n 21 -l 100000 -o bin/output_parallel_21_loop_100000.txt
echo -n "22 " && bin/prefix_scan -i tests/16k.txt -n 22 -l 100000 -o bin/output_parallel_22_loop_100000.txt
echo -n "23 " && bin/prefix_scan -i tests/16k.txt -n 23 -l 100000 -o bin/output_parallel_23_loop_100000.txt
echo -n "24 " && bin/prefix_scan -i tests/16k.txt -n 24 -l 100000 -o bin/output_parallel_24_loop_100000.txt
echo -n "25 " && bin/prefix_scan -i tests/16k.txt -n 25 -l 100000 -o bin/output_parallel_25_loop_100000.txt
echo -n "26 " && bin/prefix_scan -i tests/16k.txt -n 26 -l 100000 -o bin/output_parallel_26_loop_100000.txt
echo -n "27 " && bin/prefix_scan -i tests/16k.txt -n 27 -l 100000 -o bin/output_parallel_27_loop_100000.txt
echo -n "28 " && bin/prefix_scan -i tests/16k.txt -n 28 -l 100000 -o bin/output_parallel_28_loop_100000.txt
echo -n "29 " && bin/prefix_scan -i tests/16k.txt -n 29 -l 100000 -o bin/output_parallel_29_loop_100000.txt
echo -n "30 " && bin/prefix_scan -i tests/16k.txt -n 30 -l 100000 -o bin/output_parallel_30_loop_100000.txt
echo -n "31 " && bin/prefix_scan -i tests/16k.txt -n 31 -l 100000 -o bin/output_parallel_31_loop_100000.txt
echo -n "32 " && bin/prefix_scan -i tests/16k.txt -n 32 -l 100000 -o bin/output_parallel_32_loop_100000.txt

echo -n " 1 " && bin/prefix_scan -i tests/16k.txt -n  1 -l 100000 -s -o bin/output_s_parallel_1_loop_100000.txt
echo -n " 2 " && bin/prefix_scan -i tests/16k.txt -n  2 -l 100000 -s -o bin/output_s_parallel_2_loop_100000.txt
echo -n " 3 " && bin/prefix_scan -i tests/16k.txt -n  3 -l 100000 -s -o bin/output_s_parallel_3_loop_100000.txt
echo -n " 4 " && bin/prefix_scan -i tests/16k.txt -n  4 -l 100000 -s -o bin/output_s_parallel_4_loop_100000.txt
echo -n " 5 " && bin/prefix_scan -i tests/16k.txt -n  5 -l 100000 -s -o bin/output_s_parallel_5_loop_100000.txt
echo -n " 6 " && bin/prefix_scan -i tests/16k.txt -n  6 -l 100000 -s -o bin/output_s_parallel_6_loop_100000.txt
echo -n " 7 " && bin/prefix_scan -i tests/16k.txt -n  7 -l 100000 -s -o bin/output_s_parallel_7_loop_100000.txt
echo -n " 8 " && bin/prefix_scan -i tests/16k.txt -n  8 -l 100000 -s -o bin/output_s_parallel_8_loop_100000.txt
echo -n " 9 " && bin/prefix_scan -i tests/16k.txt -n  9 -l 100000 -s -o bin/output_s_parallel_9_loop_100000.txt
echo -n "10 " && bin/prefix_scan -i tests/16k.txt -n 10 -l 100000 -s -o bin/output_s_parallel_10_loop_100000.txt
echo -n "11 " && bin/prefix_scan -i tests/16k.txt -n 11 -l 100000 -s -o bin/output_s_parallel_11_loop_100000.txt
echo -n "12 " && bin/prefix_scan -i tests/16k.txt -n 12 -l 100000 -s -o bin/output_s_parallel_12_loop_100000.txt
echo -n "13 " && bin/prefix_scan -i tests/16k.txt -n 13 -l 100000 -s -o bin/output_s_parallel_13_loop_100000.txt
echo -n "14 " && bin/prefix_scan -i tests/16k.txt -n 14 -l 100000 -s -o bin/output_s_parallel_14_loop_100000.txt
echo -n "15 " && bin/prefix_scan -i tests/16k.txt -n 15 -l 100000 -s -o bin/output_s_parallel_15_loop_100000.txt
echo -n "16 " && bin/prefix_scan -i tests/16k.txt -n 16 -l 100000 -s -o bin/output_s_parallel_16_loop_100000.txt
echo -n "17 " && bin/prefix_scan -i tests/16k.txt -n 17 -l 100000 -s -o bin/output_s_parallel_17_loop_100000.txt
echo -n "18 " && bin/prefix_scan -i tests/16k.txt -n 18 -l 100000 -s -o bin/output_s_parallel_18_loop_100000.txt
echo -n "19 " && bin/prefix_scan -i tests/16k.txt -n 19 -l 100000 -s -o bin/output_s_parallel_19_loop_100000.txt
echo -n "20 " && bin/prefix_scan -i tests/16k.txt -n 20 -l 100000 -s -o bin/output_s_parallel_20_loop_100000.txt
echo -n "21 " && bin/prefix_scan -i tests/16k.txt -n 21 -l 100000 -s -o bin/output_s_parallel_21_loop_100000.txt
echo -n "22 " && bin/prefix_scan -i tests/16k.txt -n 22 -l 100000 -s -o bin/output_s_parallel_22_loop_100000.txt
echo -n "23 " && bin/prefix_scan -i tests/16k.txt -n 23 -l 100000 -s -o bin/output_s_parallel_23_loop_100000.txt
echo -n "24 " && bin/prefix_scan -i tests/16k.txt -n 24 -l 100000 -s -o bin/output_s_parallel_24_loop_100000.txt
echo -n "25 " && bin/prefix_scan -i tests/16k.txt -n 25 -l 100000 -s -o bin/output_s_parallel_25_loop_100000.txt
echo -n "26 " && bin/prefix_scan -i tests/16k.txt -n 26 -l 100000 -s -o bin/output_s_parallel_26_loop_100000.txt
echo -n "27 " && bin/prefix_scan -i tests/16k.txt -n 27 -l 100000 -s -o bin/output_s_parallel_27_loop_100000.txt
echo -n "28 " && bin/prefix_scan -i tests/16k.txt -n 28 -l 100000 -s -o bin/output_s_parallel_28_loop_100000.txt
echo -n "29 " && bin/prefix_scan -i tests/16k.txt -n 29 -l 100000 -s -o bin/output_s_parallel_29_loop_100000.txt
echo -n "30 " && bin/prefix_scan -i tests/16k.txt -n 30 -l 100000 -s -o bin/output_s_parallel_30_loop_100000.txt
echo -n "31 " && bin/prefix_scan -i tests/16k.txt -n 31 -l 100000 -s -o bin/output_s_parallel_31_loop_100000.txt
echo -n "32 " && bin/prefix_scan -i tests/16k.txt -n 32 -l 100000 -s -o bin/output_s_parallel_32_loop_100000.txt



echo "diff of thread count  1: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_1_loop_100000.txt
echo "diff of thread count  2: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_2_loop_100000.txt
echo "diff of thread count  3: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_3_loop_100000.txt
echo "diff of thread count  4: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_4_loop_100000.txt
echo "diff of thread count  5: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_5_loop_100000.txt
echo "diff of thread count  6: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_6_loop_100000.txt
echo "diff of thread count  7: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_7_loop_100000.txt
echo "diff of thread count  8: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_8_loop_100000.txt
echo "diff of thread count  9: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_9_loop_100000.txt
echo "diff of thread count 10: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_10_loop_100000.txt
echo "diff of thread count 11: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_11_loop_100000.txt
echo "diff of thread count 12: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_12_loop_100000.txt
echo "diff of thread count 13: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_13_loop_100000.txt
echo "diff of thread count 14: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_14_loop_100000.txt
echo "diff of thread count 15: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_15_loop_100000.txt
echo "diff of thread count 16: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_16_loop_100000.txt
echo "diff of thread count 17: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_17_loop_100000.txt
echo "diff of thread count 18: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_18_loop_100000.txt
echo "diff of thread count 19: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_19_loop_100000.txt
echo "diff of thread count 20: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_20_loop_100000.txt
echo "diff of thread count 21: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_21_loop_100000.txt
echo "diff of thread count 22: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_22_loop_100000.txt
echo "diff of thread count 23: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_23_loop_100000.txt
echo "diff of thread count 24: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_24_loop_100000.txt
echo "diff of thread count 25: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_25_loop_100000.txt
echo "diff of thread count 26: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_26_loop_100000.txt
echo "diff of thread count 27: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_27_loop_100000.txt
echo "diff of thread count 28: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_28_loop_100000.txt
echo "diff of thread count 29: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_29_loop_100000.txt
echo "diff of thread count 30: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_30_loop_100000.txt
echo "diff of thread count 31: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_31_loop_100000.txt
echo "diff of thread count 32: " && diff bin/output_sequential_loop_100000.txt bin/output_parallel_32_loop_100000.txt

echo "diff of spin thread count  1: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_1_loop_100000.txt
echo "diff of spin thread count  2: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_2_loop_100000.txt
echo "diff of spin thread count  3: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_3_loop_100000.txt
echo "diff of spin thread count  4: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_4_loop_100000.txt
echo "diff of spin thread count  5: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_5_loop_100000.txt
echo "diff of spin thread count  6: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_6_loop_100000.txt
echo "diff of spin thread count  7: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_7_loop_100000.txt
echo "diff of spin thread count  8: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_8_loop_100000.txt
echo "diff of spin thread count  9: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_9_loop_100000.txt
echo "diff of spin thread count 10: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_10_loop_100000.txt
echo "diff of spin thread count 11: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_11_loop_100000.txt
echo "diff of spin thread count 12: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_12_loop_100000.txt
echo "diff of spin thread count 13: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_13_loop_100000.txt
echo "diff of spin thread count 14: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_14_loop_100000.txt
echo "diff of spin thread count 15: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_15_loop_100000.txt
echo "diff of spin thread count 16: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_16_loop_100000.txt
echo "diff of spin thread count 17: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_17_loop_100000.txt
echo "diff of spin thread count 18: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_18_loop_100000.txt
echo "diff of spin thread count 19: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_19_loop_100000.txt
echo "diff of spin thread count 20: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_20_loop_100000.txt
echo "diff of spin thread count 21: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_21_loop_100000.txt
echo "diff of spin thread count 22: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_22_loop_100000.txt
echo "diff of spin thread count 23: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_23_loop_100000.txt
echo "diff of spin thread count 24: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_24_loop_100000.txt
echo "diff of spin thread count 25: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_25_loop_100000.txt
echo "diff of spin thread count 26: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_26_loop_100000.txt
echo "diff of spin thread count 27: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_27_loop_100000.txt
echo "diff of spin thread count 28: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_28_loop_100000.txt
echo "diff of spin thread count 29: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_29_loop_100000.txt
echo "diff of spin thread count 30: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_30_loop_100000.txt
echo "diff of spin thread count 31: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_31_loop_100000.txt
echo "diff of spin thread count 32: " && diff bin/output_sequential_loop_100000.txt bin/output_s_parallel_32_loop_100000.txt