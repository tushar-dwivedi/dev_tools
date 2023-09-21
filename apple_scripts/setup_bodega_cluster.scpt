
#set cmdList to {{"10.0.35.180", "10.0.32.45", "10.0.37.21", "10.0.37.8"}, {"10.0.39.92", "10.0.37.255", "10.0.35.53"}}
#set cmdList to {{"10.0.37.40", "10.0.36.179", "10.0.36.107"}, {"10.0.39.26", "10.0.35.164"}}
#set cmdList to {{"10.0.36.92", "10.0.36.126", "10.0.34.195"}, {"10.0.33.76", "10.0.35.123"}} # bodega 5aiczh-6cc4mkq
#set cmdList to {{"10.0.33.102", "10.0.33.192", "10.0.39.191"}, {"10.0.39.7", "10.0.38.106"}} # bodega 75xdit-autsjpu
#set cmdList to {{"10.5.115.11", "10.5.116.249", "10.5.116.138"}, {"10.5.114.35", "10.5.117.91"}}	# bodega hazkn6-7mqyfdq
#set cmdList to {{"10.0.35.49", "10.0.39.129", "10.0.37.145", "10.0.36.76"}, {"10.0.33.76", "10.0.32.141", "10.0.34.215"}}	# bodega tmphyj-282a3ys
set cmdList to {{"10.0.39.192", "10.0.37.240", "10.0.34.231", "10.0.37.144"}, {"10.0.36.252", "10.0.36.195", "10.0.38.144"}}    # w5oyn2-o2dub54

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

on setupTools()

	write text "cd ~/"
	write text "wget https://go.dev/dl/go1.16.15.linux-amd64.tar.gz"
	write text "sudo tar -C /usr/local -xzf go1.16.15.linux-amd64.tar.gz"
	write text "echo 'export PATH=$PATH:/usr/local/go/bin' >>  ~/.bashrc"
	write text "echo 'export GOPATH=$HOME/go' >> ~/.bashrc"
	write text "alias c='clear'"
	write text "source ~/bashrc"
	write text "go install github.com/go-delve/delve/cmd/dlv@latest"

	
end setupTools

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
				write text my prepareSshCmd(server_ip)
				write text "clear"
				my setupTools()
			end tell
		end if

		delay 1

		if n > 1 then
			tell second session of current tab of current window
				set server_ip to (item 2 of cmds)
				write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				write text "clear"
				my setupTools()
			end tell
		end if

		delay 1

		if n > 2 then
			tell third session of current tab of current window
                                set server_ip to (item 3 of cmds)
                                write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				write text "clear"
				my setupTools()
			end tell
		end if

		delay 1

		if n > 3 then
			tell fourth session of current tab of current window
                                set server_ip to (item 4 of cmds)
                                write text my prepareSshAddKeyCmd(server_ip)
				write text my prepareSshCmd(server_ip)
				write text "clear"
				my setupTools()
			end tell
		end if

		delay 1


		tell application "System Events" to keystroke "i" using {option down, command down}
		delay 1


		tell current window
			create tab with default profile
		end tell

	end repeat

end tell
