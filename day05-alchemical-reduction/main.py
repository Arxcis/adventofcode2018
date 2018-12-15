
import fileinput
import time
#
# ------------- Part 1 ------------------
#
polymer_new = f"0{[line for line in fileinput.input()][0]}0"
polymer_old = ""

while len(polymer_new) != len(polymer_old):
    polymer_old = polymer_new
    
    a_generator = [i for i in polymer_old[0:len(polymer_old) - 2]]
    b_generator = [i for i in polymer_old[1:len(polymer_old) - 1]]
    c_generator = [i for i in polymer_old[2:len(polymer_old) - 0]]

    polymer_new = [b \
        for a,b,c in zip(a_generator, b_generator, c_generator)\
            if True\
            and ord(b) + 32 != ord(c)\
            and ord(c) + 32 != ord(b)\
            and ord(a) + 32 != ord(b)\
            and ord(b) + 32 != ord(a)]

print(len(polymer_new)-2)