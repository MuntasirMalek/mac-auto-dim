#!/bin/bash

# Create a temporary directory for the installation
mkdir -p /tmp/mac-auto-dim-install && cd /tmp/mac-auto-dim-install

# Clone the repository
git clone https://github.com/MuntasirMalek/mac-auto-dim.git .

# Remove any existing installation
# Try different methods to ensure it stops on all macOS versions
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
launchctl remove com.user.auto_dim 2>/dev/null
launchctl bootout gui/$UID/com.user.auto_dim 2>/dev/null
pkill -f auto_dim.sh 2>/dev/null
rm -f ~/bin/auto_dim.sh ~/bin/configure.sh ~/bin/auto-dim ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
sudo rm -f /usr/local/bin/auto-dim 2>/dev/null

# Create directories
mkdir -p ~/bin
mkdir -p ~/Library/LaunchAgents

# Copy and set permissions for the scripts
cp bin/auto_dim.sh ~/bin/
cp bin/configure.sh ~/bin/
chmod 755 ~/bin/auto_dim.sh
chmod 755 ~/bin/configure.sh

# Create a symlink in /usr/local/bin for global access
sudo ln -sf ~/bin/configure.sh /usr/local/bin/auto-dim
chmod 755 /usr/local/bin/auto-dim 2>/dev/null

# Copy LaunchAgent and replace ${USER} with your username
cp LaunchAgents/com.user.auto_dim.plist ~/Library/LaunchAgents/
sed -i "" "s/\${USER}/$(whoami)/g" ~/Library/LaunchAgents/com.user.auto_dim.plist
chmod 644 ~/Library/LaunchAgents/com.user.auto_dim.plist

# Set the default idle time to 60 seconds (1 minute)
sed -i "" "s/<key>IDLE_THRESHOLD<\/key>.*/<key>IDLE_THRESHOLD<\/key>\\
     <string>60<\/string>/g" ~/Library/LaunchAgents/com.user.auto_dim.plist

# Start the auto-dim service - try multiple methods for compatibility with different macOS versions
echo "Starting service..."

# Method 1: Standard launchctl load
launchctl load ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null

# Method 2: Use bootstrap if load failed
if ! launchctl list | grep -q "com.user.auto_dim"; then
    launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
fi

# Method 3: Use legacy submit method as last resort
if ! launchctl list | grep -q "com.user.auto_dim"; then
    launchctl submit -l com.user.auto_dim -- /bin/bash ~/bin/auto_dim.sh 2>/dev/null
fi

# Check if service started
if launchctl list | grep -q "com.user.auto_dim"; then
    STATUS="started"
else
    STATUS="failed to start (you can start it manually with auto-dim --start)"
fi

# Clean up installation files
cd ~
rm -rf /tmp/mac-auto-dim-install

echo "✅ Mac Auto-Dim installed successfully with a 1-minute timeout!"
echo "   Service $STATUS."
echo "   Your screen will now dim after 1 minute of inactivity."
echo "   To configure or control, simply run: auto-dim"
echo "   For available commands, run: auto-dim --help"
