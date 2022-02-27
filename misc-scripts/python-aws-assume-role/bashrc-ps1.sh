read_credential_file() {
    python3 <<EOL
from datetime import datetime
import os, configparser
profile = os.getenv("AWS_PROFILE")
credentials_file = f"{os.getenv('HOME')}/.aws/credentials"
config = configparser.ConfigParser()
config.read(credentials_file)
expiration = config[profile]['expiration']
expiration_datetime = datetime.fromtimestamp(float(expiration))
# Time remaining in minutes
time_remaining = int((expiration_datetime - datetime.now()).total_seconds()/60)
print(time_remaining)
EOL
}

role_expiration() {
    if [[ ! -z $AWS_PROFILE ]]; then
        time_remaining=$(read_credential_file)
        if [[ ${time_remaining} > 0 ]]; then
            echo "[${AWS_PROFILE}|${time_remaining}mins]"
        else
            echo "[${AWS_PROFILE}|EXPIRED(unset AWS_PROFILE)]"
        fi
    fi
}

# Prepend AWS profile expiry info into existing bash prompt
export PS1="\e[1;33m\`role_expiration\`\e[m${PS1}"
