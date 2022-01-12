#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

virtualenv -p python3 venv
${SCRIPT_DIR}/venv/bin/python3 -m pip install boto3 pyyaml termcolor

echo -e "\n========================================================================="
echo "Append the following line to your .bashrc as an alias for easy script trigger"
echo "alias aws-jumpbox='${SCRIPT_DIR}/venv/bin/python3 ${SCRIPT_DIR}/jumpbox.py '"
