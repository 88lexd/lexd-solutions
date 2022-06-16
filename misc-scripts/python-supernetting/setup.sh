#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

virtualenv -p python3 venv
${SCRIPT_DIR}/venv/bin/python3 -m pip install netaddr ipaddress
