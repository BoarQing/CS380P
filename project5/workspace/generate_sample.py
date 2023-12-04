import random
import sys
def generate_random_pos():
    random_float = random.uniform(sys.float_info.epsilon, 4)
    return random_float

def generate_random_mass():
    random_float = random.uniform(sys.float_info.epsilon, 20)
    return random_float

def generate(count):
    with open(f"nb-{count}.txt", "w") as file:
        file.write(f"{count}\n")
        for i in range(count):
            x = generate_random_pos()
            y = generate_random_pos()
            mass = generate_random_mass()
            file.write(f"{i} {x} {y} {mass} 0 0\n")
    
def main():
    generate(int(sys.argv[1]))
if __name__ == "__main__":
    main()
