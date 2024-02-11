import sys

def validate_yaml(all_expenses):
    print("Validating the expense names to match name defined under people...")
    validated_key_names, bad_names = validate_expenses_names(all_expenses)
    if not validated_key_names:
        print('\nError: When setting the names under "expenses", the name must match whats under "people"')
        print("The following names are not valid (not case sensitive).")
        [print(f" - {name}") for name in bad_names]
        print('Double check and ensure the names under expenses match whats defined under "people".')
        sys.exit(1)

    print("Validating the expenses to ensure names are referenced correctly..")
    validated_names, bad_names = validate_names_for_spitting(all_expenses)
    if not validated_names:
        print('\nError: When using "split_with", the following names do not match whats under "people"')
        print("Not case-sensitive, match is forced to using UPPER CASE.")
        [print(f" - {name}") for name in bad_names]
        print("Double check and ensure the persons name you want to split bill with matches with the people defined.")
        sys.exit(1)


# Validate names of the key matches under people.
def validate_expenses_names(all_expenses):
    all_names_upper = [name.upper() for name in all_expenses['people']]

    bad_names = list()
    for name, expenses in all_expenses['expenses'].items():
        if name.upper() not in all_names_upper:
            bad_names.append(name)

    if len(bad_names) == 0:
        return True, None
    else:
        return False, bad_names


# Validate people names and the names referenced for splitting.
# References must match (UPPER CASE is enforced)
def validate_names_for_spitting(all_expenses):
    all_names_for_splitting = list()
    for name, expenses in all_expenses['expenses'].items():
        result = [v['split_with'] for k,v in expenses.items() if 'split_with' in v.keys()]
        if len(result) > 0:
            all_names_for_splitting.extend(result[0])

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
