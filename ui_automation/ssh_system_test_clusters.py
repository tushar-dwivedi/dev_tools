import subprocess
import time

import pyautogui

# Set up the list of IP addresses
# set cmdList to {{"10.0.35.156", "10.0.33.152", "10.0.32.218", "10.0.32.124"}, {"10.0.38.12", "10.0.38.104", "10.0.38.198"}}
# set cmdList to {{"bluemoon.rubrik-lab.com"}}
# set cmdList to {{"nebula.rubrik-lab.com"}}
ip_addresses = [["thanos.rubrik-lab.com"]]
# set cmdList to {{"b-100144-lb.rubrik-lab.com"}}
# ip_addresses = [["10.0.100.4", "10.0.100.5", "10.0.100.6", "10.0.100.7"]]

tunnel_port = "8082"


# Function to prepare the SSH command
def prepare_ssh_cmd(ip_address):
    cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{}".format(ip_address)
    return cmd


# Function to prepare the tunnel command
def prepare_tunnel_cmd(ip_address, port):
    cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{} -L {}:127.0.0.1:26258".format(ip_address, port)
    return cmd


# Function to prepare the SSH add key command
def prepare_ssh_add_key_cmd(ip_address):
    return "ssh-keyscan {} >> ~/.ssh/known_hosts".format(ip_address)


# Open Tilix
subprocess.run("tilix --maximize -w ~", shell=True)

# Wait for Tilix to open
time.sleep(2)

for tab_id, ip_address_per_tab in enumerate(ip_addresses):
    span_per_tab = len(ip_address_per_tab)

    # Split horizontally and vertically as needed
    if span_per_tab > 1:
        # Create new terminal on the right
        pyautogui.hotkey('ctrl', 'shift', 'right')
        time.sleep(1)
    if span_per_tab > 2:
        # Move to the left terminal
        pyautogui.hotkey('alt', 'left')
        # Create new terminal below
        pyautogui.hotkey('ctrl', 'shift', 'down')
        time.sleep(1)
    if span_per_tab > 3:
        # Move to the right terminal
        pyautogui.hotkey('alt', 'right')
        # Create new terminal below
        pyautogui.hotkey('ctrl', 'shift', 'down')
        time.sleep(1)

    for i, server_ip in enumerate(ip_address_per_tab):
        # move to the correct pan in the tab

        pyautogui.hotkey('ctrl', 'alt', str(i + 1))
        time.sleep(1)

        pyautogui.typewrite("devvm")
        pyautogui.press('enter')
        time.sleep(3)

        pyautogui.typewrite(prepare_ssh_add_key_cmd(server_ip))
        pyautogui.press('enter')
        time.sleep(1)
        pyautogui.typewrite(prepare_ssh_cmd(server_ip))
        pyautogui.press('enter')
        time.sleep(2)
        pyautogui.typewrite("clear")
        pyautogui.press('enter')
        time.sleep(2)

    # create a new tab
    if tab_id < len(ip_address_per_tab) - 1:
        pyautogui.hotkey('ctrl', 'shift', 't')
        time.sleep(1)

# Connect to other servers in tabs (customize as needed)
pyautogui.hotkey('ctrl', 'shift', 't')
pyautogui.typewrite("devvm")
pyautogui.press('enter')
time.sleep(3)
pyautogui.typewrite(prepare_tunnel_cmd(ip_addresses[0][0], tunnel_port))
pyautogui.press('enter')
time.sleep(1)

pyautogui.hotkey('ctrl', 'shift', 't')
pyautogui.typewrite(
    "ssh -i ~/cdm_ssh_certs/ubuntu.pem -L {}:127.0.0.1:{} ubuntu@dev_vm".format(tunnel_port, tunnel_port))
pyautogui.press('enter')
time.sleep(1)
pyautogui.typewrite(prepare_ssh_cmd(ip_addresses[0][0]))
pyautogui.press('enter')
time.sleep(2)

pyautogui.hotkey('ctrl', 'shift', 't')
pyautogui.typewrite("google-chrome https://127.0.0.1:{}/".format(tunnel_port))
pyautogui.press('enter')
