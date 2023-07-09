# display a welcome message
print("Welcome to the Future Value Calculator")
print()

choice = "y"
while choice.lower() == "y":

    # get input from the user
    monthly_investment = -1
    while monthly_investment < 0:
        monthly_investment = float(input("Enter monthly investment:\t"))
    
    yearly_interest_rate = -1
    while yearly_interest_rate < 0 or yearly_interest_rate > 15:
        yearly_interest_rate = float(input("Enter yearly interest rate:\t"))
    
    years = -1
    while years < 0 or years > 50:
        years = int(input("Enter number of years:\t\t"))

    # convert yearly values to monthly values
    monthly_interest_rate = yearly_interest_rate / 12 / 100
    months = years * 12

    print()
    print("----------------------------")
    print()

    # calculate the future value
    future_value = 0
    for i in range(1, months + 1):
        future_value += monthly_investment
        monthly_interest_amount = future_value * monthly_interest_rate
        future_value += monthly_interest_amount

        #display the results
        if i % 12 == 0:
            print("year = ", i // 12, "\tFuture Value = ", round(future_value,2))



    # see if the user wants to continue
    print()
    print()
    choice = input("Continue (y/n)? ")
    print()

print("Bye!")
