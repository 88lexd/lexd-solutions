# AWS - AssumeRole
Using a privileged account to log directly into AWS is not a good security practice. This is almost like using the root account to log onto a Linux machine.

On Linux, it is best practice to use sudo under a standard user. This should also apply to AWS when needing to manage cloud resources.

## What is AssumeRole?
AssumeRole on AWS allows you to temporarily get security crdentials into a different role. The role assuming into will generally provide more privileged access.

## Prerequisite and Setup
- Ensure you have the IAM "access and secret keys" handy. This will be required later to populate the credential config file.

- Ensure `virtualenv` is installed

  ```
  $ sudo apt install virtualenv
  ```

- Run `setup.sh` to configure Python virtual environment and libraries
  ```
  $ bash setup.sh
  <output truncated>
  ...
  ```

## How to use the script
TDB
