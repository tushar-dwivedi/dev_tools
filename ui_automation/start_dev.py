import subprocess
import time

import pyautogui

# if len(sys.argv) < 2:
#     print("Usage: python script.py cluster_uuid")
#     sys.exit(1)

# local_tunnel_port = 27017
# cluster_uuid = sys.argv[1]
# jira_ticket_id = sys.argv[2]


cmd_map = {
    "CrDB@local": ["clear", "crdb"],  # tab 1
    "Sdmain@local": ["clear", "dev_init"],  # tab 2
    "CrDB@devvm": ["clear", "devvm", "crdb"],  # tab 3
    "Sdmain@devvm": ["clear", "devvm", "dev_init"],  # tab 4
}


def split_into_subarrays(input_array):
    subarrays = []
    for i in range(0, len(input_array), 4):
        subarray = input_array[i:i + 4]
        subarrays.append(subarray)
    return subarrays


# exit(0)

# Function to prepare the SSH command
# def prepare_ssh_cmd(ip_address):
#     cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{}".format(ip_address)
#     return cmd
#
#
# # Function to prepare the tunnel command
# def prepare_tunnel_cmd(ip_address):
#     cmd = "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@{} -L 8080:127.0.0.1:26258".format(ip_address)
#     return cmd
#

# # Function to prepare the SSH add key command
# def prepare_ssh_add_key_cmd(ip_address):
#     return "ssh-keyscan {} >> ~/.ssh/known_hosts".format(ip_address)
#

# Open Tilix
subprocess.run("tilix --maximize -w ~", shell=True)
time.sleep(2)

cmdSize = len(cmd_map)

current_tab = 0
for tab_name, cmd_chain in cmd_map.items():

    pyautogui.hotkey('shift', 'ctrl', 'i')
    pyautogui.typewrite(tab_name)
    pyautogui.press('enter')

    for cmd in cmd_chain:
        pyautogui.typewrite(cmd)
        pyautogui.press('enter')
        time.sleep(5)
    # time.sleep(2)
    # pyautogui.hotkey('ctrl', 'shift', 't')
    if current_tab < len(cmd_map) - 1:
        pyautogui.hotkey('ctrl', 'shift', 't')
        time.sleep(2)

    current_tab += 1
