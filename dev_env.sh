#!/bin/bash

# Check for required tools
for tool in wmctrl xdotool devilspie2; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool is not installed. Please install it first."
        exit 1
    fi
done

# Print help message
if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [routine] [options]"
    echo "Routines:"
    echo "  dev        - Development environment"
    echo "  debug      - Debugging tools"
    echo "  triage     - Triage tools"
    echo "  metrics    - Metrics and monitoring tools"
    echo "  interview  - Interview preparation tools"
    echo "Options:"
    echo "  --mode     - Mode to run the routine in (single, multi-monitor, multi-desktop)"
    echo "Example:"
    echo "  $0 dev --mode single"
    exit 0
fi

# Check for routine argument
if [[ -z "$1" ]]; then
    echo "Error: No routine specified."
    echo "Use --help for usage information."
    exit 1
fi

ROUTINE=$1
MODE="single"

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to open applications
open_application() {
    local app=$1
    local desktop=$2
    local x=$3
    local y=$4
    local width=$5
    local height=$6
    $app &
    local app_pid=$!
    sleep 2
    wmctrl -r :ACTIVE: -t $desktop
    xdotool search --pid $app_pid windowmove $x $y windowsize $width $height
}

# Function to run routines
run_routine() {
    case $ROUTINE in
        dev)
            open_application "code" 0 0 0 800 600
            open_application "terminator" 0 800 0 800 600
            ;;
        debug)
            open_application "gdb" 0 0 0 800 600
            open_application "terminator" 0 800 0 800 600
            ;;
        triage)
            open_application "chrome" 0 0 0 800 600
            open_application "slack" 0 800 0 800 600
            ;;
        metrics)
            open_application "chrome" 0 0 0 800 600
            open_application "postman" 0 800 0 800 600
            ;;
        interview)
            open_application "obsidian" 0 0 0 800 600
            open_application "chrome" 0 800 0 800 600
            ;;
        *)
            echo "Unknown routine: $ROUTINE"
            exit 1
            ;;
    esac
}

# Determine layout based on mode
case $MODE in
    single)
        wmctrl -s 0
        run_routine
        ;;
    multi-monitor)
        # Adjust these values based on your monitor setup
        open_application "code" 0 0 0 1920 1080
        open_application "terminator" 1 1920 0 1920 1080
        ;;
    multi-desktop)
        wmctrl -s 0
        run_routine
        wmctrl -s 1
        run_routine
        ;;
    *)
        echo "Unknown mode: $MODE"
        exit 1
        ;;
esac

echo "Routine $ROUTINE started in $MODE mode."
