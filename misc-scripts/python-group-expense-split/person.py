class Person:
    def __init__(self, name, expenses):
        self.name = name.upper()
        self.expenses = expenses

        # Credit = you spent more than the split amount
        self.credit = 0

        # Debt is how much you owe
        self.debt = 0


    def add_credit(self, amount):
        self.credit += amount