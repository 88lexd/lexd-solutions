class Person:
    def __init__(self, name, expenses):
        self.name = name.upper()
        self.expenses = expenses

        # Credit = you spent more than the split amount
        self.credit = 0

        # Debt is how much you owe
        self.debt = 0

        # Used for calculating repayments
        self.final_balance = 0


    def add_credit(self, amount):
        self.credit += amount


    def add_debt(self, amount):
        self.debt += amount


    def set_final_balance(self):
        self.final_balance = self.credit - self.debt


    def balance(self):
        return self.credit - self.debt


    def in_debt(self):
        if (self.credit - self.debt) < 0:
            return True
        else:
            return False
