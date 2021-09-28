#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

virtualenv -p python3 venv
${SCRIPT_DIR}/venv/bin/python3 -m pip install -r ${SCRIPT_DIR}/requirements.txt

echo -e "\n============================================================================="
echo "Append the following line to your bash.rc as an alias for easy script trigger"
echo "============================================================================="
echo "alias assume-role='${SCRIPT_DIR}/venv/bin/python3 ${SCRIPT_DIR}/assume-role.py '"
