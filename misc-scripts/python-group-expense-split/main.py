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
    group_expense = dict()
    for person in all_expenses['people']:
        group_expense.update({
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
    calculate_all_expenses(group_expense)


def calculate_all_expenses(group_expense):
    # Calculate all the expenses and add it as the persons credit
    group_total_expense = 0
    for name, person in group_expense.items():
        if person.expenses is None:
            print(f"{name} has no expenses")
            continue

        print(f"{name} has spent:")
        person_total_expenses = 0
        for item, details in person.expenses.items():
            # Build display string for items split with specific individuals.
            if 'split_with' in details.keys():
                split_with_str = f"(split with: {', '.join(details['split_with'])})"
                # TODO: When adding split_with... I need to add as debt for the people in split_with
            else:
                split_with_str = ''

            # Add expense as credit to the person made the expense
            person.add_credit(int(details['amount']))

            print(f" - ${details['amount']} on {item} {split_with_str}")
            person_total_expenses += int(details['amount'])

        group_total_expense += person_total_expenses

    print(f"\nThe group has spent a total of: ${group_total_expense}")


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
