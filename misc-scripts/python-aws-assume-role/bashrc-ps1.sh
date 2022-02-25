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

# First save original PS1 to variable for easy rollback ($ export PS1=$PS1_ORIGINAL)
export PS1_ORIGINAL=$PS1
export PS1="\e[1;33m\`role_expiration\`\e[m\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "