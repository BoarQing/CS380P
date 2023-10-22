from subprocess import check_output
import time
input = ["\"input/fine.txt\"", "\"input/coarse.txt\""]
input_size = [100000, 100]
program = ["bst_comparsion_step1_arg.go", "bst_comparsion_step1_each_goroutine.go"]
arg = [True, False]

REPEAT = 10

def get_time(time_str):
    return float(time_str.split(":")[1].strip())

def run(input, program, work_count):
    cmd = f"go run {program} -input={input} -hash-workers={work_count}"
    print(cmd)
    total = 0.0
    for _ in range(REPEAT):
        out = check_output(cmd, shell=True).decode("ascii").strip()
        elapse_time = get_time(out)
        total += elapse_time
        time.sleep(0.5)
    print(total / REPEAT)
def main():
    for i in range(len(input)):
        for j in range(len(program)):
            if arg[j]:
                w = 1
                while w < input_size[i]:
                    run(input[i], program[j], w)
                    w *= 2
                run(input[i], program[j], input_size[i])
            else:
                run(input[i], program[j], 1)

if __name__ == "__main__":
    main()