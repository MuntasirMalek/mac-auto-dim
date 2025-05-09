#!/bin/bash

# Create a temporary directory for the installation
mkdir -p /tmp/mac-auto-dim-install && cd /tmp/mac-auto-dim-install

# Clone the repository
git clone https://github.com/MuntasirMalek/mac-auto-dim.git .

# Remove any existing installation
# Try different methods to ensure it stops on all macOS versions
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
launchctl remove com.user.auto_dim 2>/dev/null
pkill -f auto_dim.sh 2>/dev/null
rm -f ~/bin/auto_dim.sh ~/bin/configure.sh ~/bin/auto-dim ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness

# Create directories
mkdir -p ~/bin
mkdir -p ~/Library/LaunchAgents

# Copy and set permissions for the scripts
cp bin/auto_dim.sh ~/bin/
cp bin/configure.sh ~/bin/
chmod 755 ~/bin/auto_dim.sh
chmod 755 ~/bin/configure.sh

# Create a symlink for easier access
ln -sf ~/bin/configure.sh ~/bin/auto-dim

# Copy LaunchAgent and replace ${USER} with your username
cp LaunchAgents/com.user.auto_dim.plist ~/Library/LaunchAgents/
sed -i "" "s/\${USER}/$(whoami)/g" ~/Library/LaunchAgents/com.user.auto_dim.plist
chmod 644 ~/Library/LaunchAgents/com.user.auto_dim.plist

# Set the default idle time to 60 seconds (1 minute)
sed -i "" "s/<key>IDLE_THRESHOLD<\/key>.*/<key>IDLE_THRESHOLD<\/key>\\
     <string>60<\/string>/g" ~/Library/LaunchAgents/com.user.auto_dim.plist

# Start the auto-dim service
launchctl load ~/Library/LaunchAgents/com.user.auto_dim.plist

# Clean up installation files
cd ~
rm -rf /tmp/mac-auto-dim-install

echo "✅ Mac Auto-Dim installed successfully with a 1-minute timeout!"
echo "   Your screen will now dim after 1 minute of inactivity."
echo "   To configure, simply run: ~/bin/auto-dim"
echo "   For available commands, run: ~/bin/auto-dim --help"
