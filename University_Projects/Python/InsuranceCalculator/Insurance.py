 # display a welcome message
print()
print()
print("Welcome to the Minimum Insurance Calculator")
print()

choice = "y"
while choice.lower() == "y":

	#get input from the user
	replace = -1
	while replace < 0:
		replace = float(input("Enter the replacement amount:\t"))
	
	#calculate the minimum insurance
	replace_percent = .8
	percent_insured = replace_percent * 100
	minInsure = replace * replace_percent

	print()
	print("------------------------------------")
	print()

	#display the results
	print("Your property amount: $", replace)
	print()
	print("Percent insured: ", percent_insured, "%")
	print("Recommended MINIMUM insurance: $", minInsure )

	
	#see if the user would like to restart the program
	print()
	print()
	choice = input("Continue (y/n)? ")
	print()
	
	
print("Bye")
