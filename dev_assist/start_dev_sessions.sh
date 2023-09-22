#!/bin/bash

# Function to create a new Tmux session with an SSH connection
create_screen_session() {
    local session_name="$1"
    local ssh_command="$2"

    # Start iTerm and attach to the specified Tmux session
    osascript -e "tell application \"iTerm\"
        tell current window
            create tab with default profile
            tell the current session
                #write text \"tmux new-session -s ${session_name}\"
		write text \"screen -D -R ${session_name}\"
            end tell
        end tell
    end tell"

    # Wait for the Tmux session to start
    sleep 1

    # Send the Eternal Terminal command to the Tmux session
    osascript -e "tell application \"iTerm\"
        tell current window
            tell current session
                write text \"${ssh_command}\"
            end tell
        end tell
    end tell"
}

# Example: Create multiple Tmux sessions with SSH connections
create_screen_session "devvm_1" "devvm"
create_screen_session "devvm_2" "devvm"
create_screen_session "devvm_3" "devvm"

