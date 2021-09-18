#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

virtualenv -p python3 venv
source ${SCRIPT_DIR}/venv/bin/activate
pip install -r ${SCRIPT_DIR}/requirements.txt
deactivate

echo -e "\n========================================================================="
echo "Append the following line to your bash.rc as an alias for easy script trigger"
echo "alias aws-update-sg='${SCRIPT_DIR}/venv/bin/python3 ${SCRIPT_DIR}/aws-update-sg.py '"
