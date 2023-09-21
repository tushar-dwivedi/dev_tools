# The list of commands to run in each tab of the terminal window


#set cluster to "678a12ad-e0b8-453c-8a12-463c47e2296c"	# p0 issue 31 jan 2023
#set cluster to "1bb673e6-f7cc-4b72-b9ee-7f8f79f697ec"	# https://rubrikinc.slack.com/archives/C038GB9DZ/p1675175773340709
#set cluster to "9fb8f596-5777-4aa8-bbc9-9a3753212f36"	# CDM-356388 (CrDB query timeout)
#set cluster to "bd006568-359e-4e05-bf53-cca4d2f30f59"   # CDM-371220 (replication job failure, source cluster)
#set cluster to "798caf3c-2329-46eb-9afe-e1a05463a29e"	# CDM-371220 (replication job failure, destination cluster)
#set cluster to "28225903-8f3f-445d-922c-e4f3dc7e06b2" # CDM-381960 (edge crashing after 8.1.1-p1)
#set cluster to "ccda76f4-ab30-4394-986c-9f2e4ceaffc5"	# CDM-381960 (edge crash after 8.1.1, cluster 2)
#set cluster to "e7eff5e5-0ca5-4843-8aa3-f2fcf3c4ff1e" # CDM-370724 (Cluster node reboots : OOM)
#set cluster to "fe57bfc2-720e-483b-a6dd-2569619498de" # 2 kronos clusters
#set cluster to "5a26d797-3d4a-4741-b36e-6bbf057a2f7e"	# CDM-370606 (high CPU on one node)
#set cluster to "f02f0145-4e72-4053-a10b-b44d9fd55a81"	# CDM-363260 (MSSQL_LOG_REPLICATE failing with RBK91010002, seems like n/w issue)

#set cluster to "1a83d55d-c676-4da1-b046-d4939c44c78b" # CDM-385655 (Cassandra snapshot partition are 100% full on all nodes)
#set cluster to "9b0fc664-025b-4f74-9e24-c664f8e4ed69"	# CDM-386042 (P0 issue, CrDB not accepting connections after upgrade)
#set cluster to "1bb673e6-f7cc-4b72-b9ee-7f8f79f697ec"	# CDM-331145 & CDM-358017 (high CPU & memory usage, increase priority)
#set cluster to "6335b299-bce5-4fc4-9350-4e54608ed4ec"	# CDM-385794 partitions are lost, most likely not a CrDB issue
#set cluster to "dc7c9ffd-dae0-4de9-955d-d849fd3f9f56"	# CDM-386122 (Nodes are periodically going STALE)
#set cluster to "9f1ec756-fea9-49f2-a266-41294cd52fb8"	# CDM-386022 (Random Nodes going down in a week and auto reviving)
#set cluster to "9eb4c328-f722-458a-a083-d9ec76743d8c"	# CDM-385217 (prechecks failing for decommission)
#set cluster to "5823564e-cb5b-49a6-b9ab-147695363032"	# CDM-386604 (20 out of 200 nodes are down)

#set cluster to "8262eaf4-8f4c-48bf-a649-87af9581d248"	# CDM-394917
set cluster to "69994835-0473-492d-8a2f-856cdf7fdf42"	# CDM-395090 (node stale, LH of sd.node table)
#set cluster to "0a0261b4-8559-4880-b847-463b55659dbf"	# CDM-394589

set cmdList to {{"portal connect", "portal connect --cluster-uuid " & (cluster as string)}, {"forward_crdb " & (cluster as string)}, {"open https://127.0.0.1:27017/"}}

# You can append to the list just to break up really long lines
# set cmdList to cmdList & {"ssh user@host3.example.com"}


tell application "iTerm2"
	# Not sure how to create an "empty" window so for the window we pick the
	# first command in the list
	set newWindow to (create window with default profile)

	# Personal preference - adjust as you see fit.  You can get fancier
	# by getting the desktop size and setting these relative to that if you want
	tell newWindow
		# bounds are top left X, Y, width, height
		set bounds to {75,150,2000,1200}
	end tell

	tell newWindow
		repeat with x from 1 to count of cmdList
			set cmds to (item x of cmdList)
			set tb to current tab
			log "cmds: " & cmds
			tell first session of  tb
				repeat with y from 1 to count of cmds
					set cmd to (item y of cmds)
					log "cmd : " & cmd
					write text cmd
					delay 2
				end repeat
				delay 5
			end tell
			create tab with default profile
		end repeat
	end tell
end tell
