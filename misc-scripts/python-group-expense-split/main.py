from person import Person
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

    print("Validating the expenses to ensure names are referenced correctly..")
    validated_names, bad_names = validate_names(all_expenses)
    if not validated_names:
        print('\nError: When using "split_with", the following names do not match whats under "people"')
        print("Not case-sensitive, match is forced to using UPPER CASE.")
        [print(f" - {name}") for name in bad_names]
        print("Double check and ensure the persons name you want to split bill with matches with the people defined.")
        sys.exit(1)


# Validate people names and the names referenced for splitting.
# References must match (UPPER CASE is enforced)
def validate_names(all_expenses):
    all_names_for_splitting = list()
    for name, expenses in all_expenses['expenses'].items():
        all_names_for_splitting.extend([
            v['split_with'] for k,v in expenses.items() if 'split_with' in v.keys()][0])

    # Make unique
    uniq_names_for_splitting = list(set(all_names_for_splitting))

    # Make all names upper case
    names_for_splitting_upper = [name.upper() for name in uniq_names_for_splitting]
    all_names_upper = [name.upper() for name in all_expenses['people']]

    # Check if name is referenced correctly
    bad_names = list()
    for name in names_for_splitting_upper:
        if name not in all_names_upper:
            bad_names.append(name)


    if len(bad_names) == 0:
        return True, None
    else:
        return False, bad_names


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
