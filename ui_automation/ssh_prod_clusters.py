import subprocess
import sys
import time

import pyautogui

if len(sys.argv) < 2:
    print("Usage: python script.py cluster_uuid")
    sys.exit(1)

local_tunnel_port = 27017
cluster_uuid = sys.argv[1]
jira_ticket_id = sys.argv[2]

if len(sys.argv) > 3:
    local_tunnel_port = sys.argv[3]

JIRA_BASE_URL = "https://rubrik.atlassian.net/browse"

cmd_map = {
    "connect to a cluster node": [
        "clear",
        "portal connect",
        "sleep 5",
        "portal access gain --jira {}/{} --cluster-uuid {}".format(JIRA_BASE_URL, jira_ticket_id, cluster_uuid),
        "portal connect --cluster-uuid {}".format(cluster_uuid),
        jira_ticket_id,
    ],  # tab 1
    "port forward to cluster": [
        "clear",
        "forward_crdb {} {}".format(cluster_uuid, local_tunnel_port),
        jira_ticket_id,
    ],  # tab 2
    "open browser": [
        "clear",
        "xdg-open https://127.0.0.1:{}".format(local_tunnel_port),
    ],  # tab 3
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
    pyautogui.typewrite("{}: {}".format(cluster_uuid, tab_name))
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
