string = input("Enter a string: ")

result = ""

for i in string:
    if i not in result:
        result = result + i

print("Result:", result)
