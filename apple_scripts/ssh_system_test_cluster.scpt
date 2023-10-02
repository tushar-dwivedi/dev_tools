
#set cmdList to {{"10.0.35.156", "10.0.33.152", "10.0.32.218", "10.0.32.124"}, {"10.0.38.12", "10.0.38.104", "10.0.38.198"}}
#set cmdList to {{"bluemoon.rubrik-lab.com"}}
#set cmdList to {{"nebula.rubrik-lab.com"}}
#set cmdList to {{"uptime.rubrik-lab.com"}}
#set cmdList to {{"b-100144-lb.rubrik-lab.com"}}
set cmdList to {{"10.0.100.4", "10.0.100.5", "10.0.100.6", "10.0.100.7"}}

on prepareSshCmd(ip_address)
	set ssh_cmd to "ssh_cluster ubuntu@" & (ip_address as string)
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
				write text "devvm"
				delay 3
				write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				delay 1
				write text "clear"
			end tell
		end if

		delay 1

		if n > 1 then
			tell second session of current tab of current window
				set server_ip to (item 2 of cmds)
				write text "devvm"
				delay 3
				write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				delay 1
				write text "clear"
			end tell
		end if

		delay 1

		if n > 2 then
			tell third session of current tab of current window
                                set server_ip to (item 3 of cmds)
				write text "devvm"
				delay 3
				write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				delay 1
				write text "clear"
			end tell
		end if

		delay 1

		if n > 3 then
			tell fourth session of current tab of current window
				set server_ip to (item 4 of cmds)
				write text "devvm"
				delay 3
				write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				delay 1
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
		write text "devvm"
		delay 3
		set server_ip to(item 1 of (item 1 of cmdList))
		write text "tunnel_bodega_port " & server_ip & " 8081"
		delay 2
		write text my prepareSshCmd(server_ip)
		delay 1
	end tell

	tell current window
		create tab with default profile
		delay 1
	end tell

	tell first session of current tab of current window
		write text "ssh -i ~/cdm_ssh_certs/ubuntu.pem -L 8081:127.0.0.1:8081 ubuntu@dev_vm"
	end tell

	tell current window
                create tab with default profile
                delay 1
        end tell

	tell first session of current tab of current window
		"open https://127.0.0.1:8081/"
	end tell

end tell
