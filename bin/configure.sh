#!/usr/bin/env bash

# Auto-Dim Configuration Helper
# This script makes it easy to adjust auto-dim settings

# Colors for prettier output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if the app is installed
if [ ! -f "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" ]; then
    echo "Auto-Dim doesn't seem to be installed yet."
    echo "Please install it first by following the instructions in the README."
    exit 1
fi

# Function to show current settings
show_settings() {
    # Extract current idle threshold
    current_time=$(grep -A 1 "IDLE_THRESHOLD" "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" | grep string | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    
    echo -e "${BLUE}Current Settings:${NC}"
    echo -e "• Idle time before dimming: ${GREEN}$current_time seconds${NC}"
    
    # Check if the service is running
    if launchctl list | grep -q "com.user.auto_dim"; then
        echo -e "• Status: ${GREEN}Running${NC}"
    else
        echo -e "• Status: ${RED}Stopped${NC}"
    fi
}

# Function to update idle time
update_idle_time() {
    # Make sure the input is a number
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid number of seconds."
        return 1
    fi
    
    # Create a temporary file with the new content
    temp_file=$(mktemp)
    
    # Create the new plist file with the updated IDLE_THRESHOLD
    awk -v new_time="$1" '
    /<key>EnvironmentVariables<\/key>/,/<\/dict>/ {
        if (!env_vars_found) {
            print "   <key>EnvironmentVariables</key>"
            print "   <dict>"
            print "     <key>PATH</key>"
            print "     <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>"
            print "     <key>IDLE_THRESHOLD</key>"
            print "     <string>" new_time "</string>"
            print "   </dict>"
            env_vars_found = 1
        }
        if (/<\/dict>/) env_vars_section = 0
        next
    }
    { print }
    ' "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" > "$temp_file"
    
    # Replace the original file with the updated one
    mv "$temp_file" "$HOME/Library/LaunchAgents/com.user.auto_dim.plist"
    
    echo -e "Idle time updated to ${GREEN}$1 seconds${NC}."
    echo "Restarting service for changes to take effect..."
    
    # Restart the service
    stop_service
    start_service
    
    echo -e "${GREEN}Done!${NC} Auto-dim will now activate after $1 seconds of inactivity."
}

# Function to start the service
start_service() {
    # Try different methods to ensure service starts
    launchctl load "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" 2>/dev/null
    
    # If that didn't work, try bootstrap method
    if ! launchctl list | grep -q "com.user.auto_dim"; then
        launchctl bootstrap gui/$UID "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" 2>/dev/null
    fi
    
    # If still not started, try legacy method
    if ! launchctl list | grep -q "com.user.auto_dim"; then
        launchctl submit -l com.user.auto_dim -- /bin/bash "$HOME/bin/auto_dim.sh" 2>/dev/null
    fi
}

# Function to stop the service
stop_service() {
    # Try different methods to ensure it stops
    launchctl unload "$HOME/Library/LaunchAgents/com.user.auto_dim.plist" 2>/dev/null
    launchctl remove "com.user.auto_dim" 2>/dev/null
    launchctl bootout gui/$UID/com.user.auto_dim 2>/dev/null
    
    # As a fallback, kill any running processes
    pkill -f "auto_dim.sh" 2>/dev/null
}

# Function to control the service
control_service() {
    if [ "$1" == "start" ]; then
        start_service
        echo -e "${GREEN}Auto-dim started!${NC}"
    elif [ "$1" == "stop" ]; then
        stop_service
        echo -e "${GREEN}Auto-dim stopped!${NC}"
    else
        echo "Invalid command. Use 'start' or 'stop'."
    fi
}

# Show menu
show_menu() {
    echo -e "${BLUE}=== Auto-Dim Configuration ===${NC}"
    echo
    show_settings
    echo
    echo -e "${BLUE}What would you like to do?${NC}"
    echo "1) Change idle time"
    echo "2) Start Auto-Dim"
    echo "3) Stop Auto-Dim"
    echo "4) Exit"
    echo
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            echo
            read -p "Enter new idle time in seconds (e.g., 60 for 1 minute): " seconds
            update_idle_time "$seconds"
            exit 0
            ;;
        2)
            control_service "start"
            exit 0
            ;;
        3)
            control_service "stop"
            exit 0
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            exit 1
            ;;
    esac
}

# Get script name without path for help display
SCRIPT_NAME=$(basename "$0")

# If arguments are provided, use command line mode
if [ $# -gt 0 ]; then
    case "$1" in
        --time|-t)
            if [ -z "$2" ]; then
                echo "Please provide the idle time in seconds."
                echo "Example: $SCRIPT_NAME --time 120"
                exit 1
            fi
            update_idle_time "$2"
            ;;
        --start|-s)
            control_service "start"
            ;;
        --stop|-o)
            control_service "stop"
            ;;
        --status|-i)
            show_settings
            ;;
        --help|-h)
            echo "Usage:"
            echo "  $SCRIPT_NAME                  # Interactive menu"
            echo "  $SCRIPT_NAME --time SECONDS   # Set idle time to any number of seconds"
            echo "  $SCRIPT_NAME --start          # Start the service"
            echo "  $SCRIPT_NAME --stop           # Stop the service"
            echo "  $SCRIPT_NAME --status         # Show current settings"
            echo "  $SCRIPT_NAME --help           # Show this help"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help to see available options."
            exit 1
            ;;
    esac
    exit 0
fi

# No arguments, launch interactive menu
show_menu 