digits = "0123456789"

while (True):
    line = input()

    curr_number = ""

    for ch in line:
        if ch in digits:
            curr_number += ch
        elif ch == "{":
            print(",RuleNode(", end="")
            print(curr_number, end="")
            print(", [", end="")
            curr_number = ""
        elif ch == ",":
            print("RuleNode(", end="")
            print(curr_number, end="")
            print("),", end="")
            curr_number = ""
        elif ch == "}":
            if curr_number != "":
                print("RuleNode(", end="")
                print(curr_number, end="")
                print(")", end="")
                curr_number = ""
            print("])", end="")
    print()