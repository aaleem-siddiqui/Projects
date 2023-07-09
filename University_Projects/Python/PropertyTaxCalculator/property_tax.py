 # display a welcome message
print()
print()
print("Welcome to the Property Tax Calculator")
print()

choice = "y"
while choice.lower() == "y":

	#get input from the user
	actualValue = -1
	while actualValue < 0:
		actualValue = float(input("Enter the actual value of your property:\t"))
	
	#calculate the Assessment value
	assValue = actualValue * .6
	
	#calculate the property tax
	propTax = (assValue / 100) * .72

	print()
	print("------------------------------------")
	print()

	#display the results
	print("Your property amount: $", actualValue)
	print()
	print("Assessment value of property: $", assValue)
	print("Tax for this property: $", \
              format(propTax, ',.2f'), sep='')

	
	#see if the user would like to restart the program
	print()
	print()
	choice = input("Continue (y/n)? ")
	print()
	
	
print("Bye")
