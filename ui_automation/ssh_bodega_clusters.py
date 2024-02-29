import subprocess
import sys
import time

import pyautogui


def split_into_subarrays(input_array):
    subarrays = []
    for i in range(0, len(input_array), 4):
        subarray = input_array[i:i + 4]
        subarrays.append(subarray)
    return subarrays


if len(sys.argv) < 2:
    print("Usage: python script.py ip_Address_csv_string")
    sys.exit(1)

# The first argument (sys.argv[0]) is the script name, so we start from index 1
ip_address_str = sys.argv[1]
ip_list = ip_address_str.split(',')

# Remove any empty elements (e.g., caused by the trailing comma)
ips = [ip.strip() for ip in ip_list if ip.strip()]

ip_addresses = split_into_subarrays(ips)

# Print the resulting list of IP addresses
print(ip_addresses)


# exit(0)

# Function to prepare the SSH command
def prepare_ssh_cmd(ip_address):
    cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{}".format(ip_address)
    return cmd


# Function to prepare the tunnel command
def prepare_tunnel_cmd(ip_address):
    cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{} -L 8080:127.0.0.1:26258".format(ip_address)
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

    pyautogui.hotkey('shift', 'ctrl', 'i')
    pyautogui.typewrite("ssh to {} nodes, tab ID: {}".format(span_per_tab, tab_id))
    pyautogui.press('enter')

    time.sleep(2)
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
        pyautogui.typewrite(prepare_ssh_add_key_cmd(server_ip))
        pyautogui.press('enter')
        time.sleep(2)
        pyautogui.typewrite(prepare_ssh_cmd(server_ip))
        pyautogui.press('enter')
        time.sleep(2)
        pyautogui.typewrite("clear")
        pyautogui.press('enter')
        time.sleep(1)

    pyautogui.hotkey('alt', 'ctrl', 'i')
    # create a new tab
    if tab_id < len(ip_addresses) - 1:
        pyautogui.hotkey('ctrl', 'shift', 't')
        time.sleep(1)

# Connect to other servers in tabs (customize as needed)
pyautogui.hotkey('ctrl', 'shift', 't')

pyautogui.hotkey('shift', 'ctrl', 'i')
pyautogui.typewrite("tunnel to {}".format(ip_addresses[0][0]))
pyautogui.press('enter')

pyautogui.typewrite(prepare_tunnel_cmd(ip_addresses[0][0]))
pyautogui.press('enter')
time.sleep(1)

pyautogui.hotkey('ctrl', 'shift', 't')

pyautogui.hotkey('shift', 'ctrl', 'i')
pyautogui.typewrite("ssh to {}".format(ip_addresses[0][0]))
pyautogui.press('enter')

pyautogui.typewrite(prepare_ssh_cmd(ip_addresses[0][0]))
pyautogui.press('enter')
time.sleep(1)
