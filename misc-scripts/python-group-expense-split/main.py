from person import Person
import validation as v
import yaml
import sys


def main():
    print("===============================")
    print("Group Expense Splitter Script")
    print("Author: Alex Dinh")
    print("===============================\n")

    try:
        expenses_file = sys.argv[1]
    except IndexError:
        print("Error: at least one argument is required to specify the input file.")
        sys.exit(1)

    print(f"Reading expenses from {expenses_file}")
    all_expenses = read_yaml(expenses_file)
    v.validate_yaml(all_expenses)

    print("Building instance for each person...")
    group = dict()
    for person in all_expenses['people']:
        group.update({
            person: Person(
                    name=person,
                    expenses=all_expenses['expenses'].get(person, None)
                    )
            }
        )

    print("Adding up expenses for each person...")

    print("\n===============")
    print("Expense details")
    print("===============")
    calculate_all_expenses(group)


def calculate_all_expenses(group):
    group_total_expense = 0
    for name, person in group.items():
        if person.expenses is None:
            print(f"{name} has no expenses")
            continue

        print(f"{name} has spent:")
        person_total_expenses = 0
        for item, details in person.expenses.items():
            # Build display string for items split with specific individuals.
            if 'split_with' in details.keys():
                split_with_str = f"(split with: {', '.join(details['split_with'])})"
                calculate_split_debt(group, details['split_with'], float(details['amount']))
            else:
                split_with_str = ''
                calculate_all_debt(group, float(details['amount']))

            # Add expense as credit to the person made the expense
            person.add_credit(float(details['amount']))

            print(f" - ${details['amount']} on {item} {split_with_str}")
            person_total_expenses += float(details['amount'])

        group_total_expense += person_total_expenses

    group_total_expense_str = '{0:.2f}'.format(group_total_expense)
    print(f"\nThe group has spent a total of: ${group_total_expense_str}")


def calculate_split_debt(group, split_with, amount):
    # Accumulate debt for those splitting the expense
    split_between_number = len(split_with)
    debt_per_person = float(amount / split_between_number)
    for person in split_with:
        group[person].add_debt(debt_per_person)


def calculate_all_debt(group, amount):
    # General expenses are split between everyone
    split_between_number = len(group)
    debt_per_person = float(amount / split_between_number)
    for person in group:
        group[person].add_debt(debt_per_person)


def read_yaml(input_file):
    with open(input_file, 'r') as f:
        try:
            config = yaml.load(f, Loader=yaml.BaseLoader)
            return config
        except yaml.YAMLError as exc:
            print(exc)
            raise Exception(f"Cannot parse {input_file} file")


if __name__ == "__main__":
    main()
