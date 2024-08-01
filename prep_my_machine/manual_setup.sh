
# 1. Account setup
# https://rubrik.atlassian.net/wiki/spaces/SPARK/pages/279347217/Development+Environment#1.-Account-Setup
# https://rubrik.atlassian.net/wiki/spaces/SPARK/pages/279281687/Ubuntu

sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update && sudo apt install ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt install \
    git \  # For version management
    python3 \  # For environment bootstrapping
    build-essential \  # For compiling Python packages
    php-cli php-curl curl \  # For Arcanist
    rename

# Github setup
ssh-keygen -t rsa -C "tushar.dwivedi@rubrik.com"
Name the file as /home/tushardwivedi/.ssh/id_rsa_github, and keep passphrase empty

ssh-add ~/.ssh/id_rsa_github

Go to https://github.com/settings/keys, and create a new ssh key:

cat ~/.ssh/id_rsa_github, and add the copy paste the output in the  github ssh-key, and then "authorize" the key.

git config --global user.email "tushar.dwivedi@rubrik.com"
git config --global user.name "Tushar Dwivedi"


ssh-keygen -t rsa -C "tdwivedi2708@gmail.com"

/home/tushardwivedi/.ssh/id_rsa_personal (empty passphrase)

ssh-add ~/.ssh/id_rsa_personal





