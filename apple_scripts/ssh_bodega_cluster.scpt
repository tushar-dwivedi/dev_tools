#set cmdList to {{"10.0.115.2", "10.0.115.3", "10.0.115.4", "10.0.115.5"}, {"10.0.115.130", "10.0.115.131", "10.0.115.132", "10.0.115.133"}} # stress cluster

#set cmdList to {{"10.0.37.52", "10.0.34.227", "10.0.32.238", "10.0.35.131"}}									#	new 4 nodes prod brik ( jvbm77-mh4uw2u )
#set cmdList to {{"10.0.35.244", "10.0.35.211", "10.0.39.243", "10.0.34.172"}, {"10.0.32.127", "10.0.33.149", "10.0.33.200", "10.0.35.128"}}	#	8-node prodbrik ( 4psu3w-o23bp6y )
#set cmdList to {{"10.0.36.32", "10.0.32.171", "10.0.37.39", "10.0.38.67"}, {"10.0.36.68", "10.0.35.40", "10.0.36.63", "10.0.35.20"}}		#	new 8-node cluster ( wvymxg-p2yeqsw )
set cmdList to {{"10.0.39.237", "10.0.38.104", "10.0.38.72", "10.0.34.94"}}									#	4 node cluster ( 6x5gvi-got2hes )
#set cmdList to {{"10.0.36.84", "10.0.34.200", "10.0.35.2", "10.0.39.48"}}				# 3 node cluster to test gojq setup	( 2435n2-de3ea7w )
#set cmdList to {{"10.0.34.157"}}

on prepareSshCmd(ip_address)
	set ssh_cmd to "ssh -i ~/cdm_ssh_certs/ubuntu.pem ubuntu@" & (ip_address as string)
	log "ssh_cmd: " & ssh_cmd
	return ssh_cmd
end prepareSshCmd


on prepareSshAddKeyCmd(ip_address)
	set ssh_add_cmd to "ssh-keyscan " & ip_address & " >> ~/.ssh/known_hosts"
        log "ssh_add_cmd: " & ssh_add_cmd
        return ssh_add_cmd
end prepareSshAddKeyCmd


tell application "iTerm2"
	activate
	set newWindow to (create window with default profile)
	tell newWindow
		# bounds are top left X, Y, width, height
		set bounds to {75,10,2000,1200}
	end tell
	delay 1


	repeat with x from 1 to count of cmdList
		set cmds to (item x of cmdList)

		log cmds

		set n to count of cmds

		# launch session "Default Session"

		if n > 1 then
			# split vertically
			tell application "System Events" to keystroke "d" using command down
			delay 1
		end if

		if n > 2 then
			# previus panel
			tell application "System Events" to keystroke "[" using command down
			delay 1
			# split horizontally
			tell application "System Events" to keystroke "d" using {shift down, command down}
			delay 1
		end if
		
		if n > 3 then
			# next panel
			tell application "System Events" to keystroke "]" using command down
			delay 1
			# split horizontally
			tell application "System Events" to keystroke "d" using {shift down, command down}
		end if


		if n > 0 then
			tell first session of current tab of current window
				set server_ip to (item 1 of cmds)
				write text my prepareSshAddKeyCmd(server_ip)
				#write text "tmux"
				delay 1
				write text my prepareSshCmd(server_ip)
				write text "clear"
			end tell
		end if

		delay 1

		if n > 1 then
			tell second session of current tab of current window
				set server_ip to (item 2 of cmds)
				write text my prepareSshAddKeyCmd(server_ip)
				#write text "tmux"
                                delay 1
				write text my prepareSshCmd(server_ip)
				write text "clear"
			end tell
		end if

		delay 1

		if n > 2 then
			tell third session of current tab of current window
                                set server_ip to (item 3 of cmds)
                                write text my prepareSshAddKeyCmd(server_ip)
				#write text "tmux"
                                delay 1
				write text my prepareSshCmd(server_ip)
				write text "clear"
			end tell
		end if

		delay 1

		if n > 3 then
			tell fourth session of current tab of current window
                                set server_ip to (item 4 of cmds)
                                write text my prepareSshAddKeyCmd(server_ip)
				#write text "tmux"
                                delay 1
				write text my prepareSshCmd(server_ip)
				write text "clear"
			end tell
		end if

		delay 1


		tell application "System Events" to keystroke "i" using {option down, command down}
		delay 1


		tell current window
			create tab with default profile
		end tell

	end repeat

	tell first session of current tab of current window
		#write text "tmux"
                delay 1
		write text "tunnel_bodega ubuntu@" & (item 1 of (item 1 of cmdList))
	end tell

	tell current window
		create tab with default profile
		delay 1
	end tell

	tell first session of current tab of current window
		#write text "tmux"
		delay 1
		write text "ssh_cluster ubuntu@" & (item 1 of (item 1 of cmdList))
	end tell



end tell
