# Group Expense Splitting Script
A basic Python script to help with group expense splitting.

This takes in a YAML file with the expenses defined and the script will peform the required calculations.

## How to Setup
This script requires PyYAML which we can install using Python virtualenv
```
$ virtualenv -p python3 venv
$ ./venv/bin/python3 -m pip install pyyaml
```

## How to use the script
### Configure your expenses
Refer to the `sample-expenses.yml` or `sample-expenses-simple.yml` files and create your own YAML to represent the expenses for the group spending.

It is important to note the following:
 - Must define all the names in the group for splitting under the `people` section.
    - Names are not case sensitive but do recommend to use lowercases.
 - The `expenses` section, you must define a section for each `person` that has made an expense. The names here must match a name defined under the `people` section.
    - Under each person, you then define the actual expense itself along with:
        - The amount spent and if required, who this is being split with (if `split_with` is not defined, then the amount will be split between the whole group)
 - Names under `split_with` needs to match names defined in the `people` section.

### Execute the Script
Here is an example on how the sample expense YAML is parsed and the calculation it returns.

```
$ source ./venv/bin/activate
$ python3 main.py ./sample-expenses-simple.yml
===============================
Group Expense Splitter Script
Author: Alex Dinh
===============================

Reading expenses from ./sample-expenses-simple.yml
Validating the expense names to match name defined under people...
Validating the expenses to ensure names are referenced correctly..
Building instance for each person...
Adding up expenses for each person...

===============
Expense Details
===============
alex has spent:
 - $200 on dinner
jay has spent:
 - $100 on drinks (split with: jay, mandy)
lambo has spent:
 - $200 on hotel
mandy has no expenses

The group has spent a total of: $500.00

=========================
Group Debt/Credit Totals
=========================
alex is receiving $100.00 from the group based on:
 - Credit: $200.00
 - Debt: -$100.00
jay owes $50.00 to the group money based on:
 - Credit: $100.00
 - Debt: -$150.00
lambo is receiving $100.00 from the group based on:
 - Credit: $200.00
 - Debt: -$100.00
mandy owes $150.00 to the group money based on:
 - Credit: $0.00
 - Debt: -$150.00

=========================
Group Payout Information
=========================
 - JAY pays ALEX $50.00
 - MANDY pays ALEX $50.00
 - MANDY pays LAMBO $100.00
```
