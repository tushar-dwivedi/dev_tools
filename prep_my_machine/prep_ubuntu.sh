#!/bin/bash

# Update the package list
sudo apt update

# Install snap if not already installed
if ! command -v snap &> /dev/null; then
    echo "Snap is not installed. Installing snapd..."
    sudo apt install -y snapd
fi

# Install development tools via snap
echo "Installing development tools via snap..."

# Terminal tools
# sudo snap install --classic terminator               # Terminator (Terminal emulator)
sudo snap install --classic tilix                    # Tilix (Advanced terminal emulator)

# Version control
sudo snap install gitkraken                          # GitKraken (Git GUI)
sudo snap install --classic git                      # Git (Command-line version)

# Docker and container management
sudo snap install docker                             # Docker

# Editors
sudo snap install --classic obsidian                 # Obsidian (Note-taking app)
sudo snap install --classic sublime-text             # Sublime Text
sudo snap install --classic markdown-editor          # Markdown editor

# IDEs and editors
sudo snap install --classic code                   # Visual Studio Code
sudo snap install --classic intellij-idea-community # IntelliJ IDEA Community Edition
sudo snap install --classic goland                  # GoLand (Go IDE)
sudo snap install --classic pycharm-community       # PyCharm Community Edition

# Web development
# sudo snap install --classic webstorm                 # WebStorm (JavaScript IDE)
sudo snap install --classic postman                  # Postman (API testing)

# Productivity tools
sudo snap install --classic slack                   # Slack (Team communication)
sudo snap install --classic todoist                 # Todoist (Task management)

# SSH and Remote Access
sudo snap install --classic openssh                 # OpenSSH (SSH client)
sudo snap install --classic remmina                  # Remmina (Remote desktop client)

# Debugging and automation
sudo snap install --classic insomnia                # Insomnia (REST client and debugging)
sudo snap install --classic automation-tool         # Custom tool for automation (if available)
sudo snap install --classic pprof-viewer            # pprof-viewer (Visualizing Go pprof data)

# Desktop and window management
sudo apt install -y wmctrl                          # wmctrl (Window management command)
sudo apt install -y xdotool                         # xdotool (Simulate keyboard and mouse input)
sudo apt install -y devilspie2                      # devilspie2 (Advanced window manipulation)

# Programming languages and runtimes
sudo snap install --classic python                  # Python
sudo snap install node                              # Node.js
sudo snap install go                                # Go language

# Install Go language (latest version available)
sudo snap install go                                # Go language

# Install Java JDK
sudo snap install --classic openjdk                  # OpenJDK (Java Development Kit)

# Install Scala
sudo snap install scala                             # Scala


# Python packages for automation
echo "Creating and installing Python packages from requirements.txt..."

# Create a virtual environment
python3 -m venv ~/.venv
source ~/.venv/bin/activate

# Install Python packages
pip install -r requirements.txt

echo "Development tools and Python packages installed successfully!"

# Optionally, add any additional tools or commands here
# For example:
# sudo snap install <tool-name>

# Reminder to reboot or start using the installed applications
echo "You may need to reboot your system or start using the installed applications."
