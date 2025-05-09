# Mac Auto-Dim

Automatically dims your Mac's screen after a period of inactivity and restores brightness when you return.

## Requirements

Install these with Homebrew:
```bash
brew install brightness bc
```

## Quick Installation (1-Minute Default)

Option 1: Run this single command in your Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/MuntasirMalek/mac-auto-dim/main/install.sh | bash
```

Option 2: Or, if you prefer to see the installation process step by step:

```bash
# Create a temporary directory for the installation
mkdir -p /tmp/mac-auto-dim-install && cd /tmp/mac-auto-dim-install

# Clone the repository
git clone https://github.com/MuntasirMalek/mac-auto-dim.git .

# Remove any existing installation
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
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
sed -i '' "s/\${USER}/$(whoami)/g" ~/Library/LaunchAgents/com.user.auto_dim.plist
chmod 644 ~/Library/LaunchAgents/com.user.auto_dim.plist

# Set the default idle time to 60 seconds (1 minute)
sed -i '' "s/<key>IDLE_THRESHOLD<\/key>.*/<key>IDLE_THRESHOLD<\/key>\\
     <string>60<\/string>/g" ~/Library/LaunchAgents/com.user.auto_dim.plist

# Start the auto-dim service
launchctl load ~/Library/LaunchAgents/com.user.auto_dim.plist

# Clean up installation files
cd ~
rm -rf /tmp/mac-auto-dim-install

echo "✅ Mac Auto-Dim installed successfully with a 1-minute timeout!"
echo "   Your screen will now dim after 1 minute of inactivity."
echo "   To configure, simply run: ~/bin/auto-dim"
```

That's it! Your screen will now automatically dim after 1 minute of inactivity.

## Easy Configuration

Auto-dim includes a user-friendly configuration tool. You can run it in two ways:

### Interactive Menu

Simply run:
```bash
~/bin/auto-dim
```

This brings up a simple menu where you can:
- Change the idle time before dimming
- Start or stop the auto-dim service
- View current settings

### Command Line

Quick commands for common actions:

```bash
# Change idle time to 2 minutes (120 seconds)
~/bin/auto-dim --time 120

# Change to 30 seconds
~/bin/auto-dim --time 30

# Turn auto-dim on
~/bin/auto-dim --start

# Turn auto-dim off
~/bin/auto-dim --stop

# Show current settings
~/bin/auto-dim --status

# Show help
~/bin/auto-dim --help
```

## Uninstall

To remove auto-dim, simply run:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist
rm -f ~/bin/auto_dim.sh ~/bin/configure.sh ~/bin/auto-dim ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
```

## How it Works

- The script checks for system idle time every 5 seconds
- If the system has been idle for more than the configured time, it saves the current brightness level and dims the screen
- When activity is detected, it restores the previous brightness level
- Logs are written to `~/Library/Logs/auto_dim.{out,err}.log`

## Troubleshooting

1. If the service isn't starting:
   ```bash
   # Check the log files
   cat ~/Library/Logs/auto_dim.out.log
   cat ~/Library/Logs/auto_dim.err.log
   ```

2. If the screen isn't dimming:
   - Make sure `brightness` command works: `brightness -l`
   - Check if the script is running: `ps aux | grep auto_dim`

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements!

## License

MIT License - Feel free to use and modify as needed! 