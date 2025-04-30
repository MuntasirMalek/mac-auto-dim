# Mac Auto-Dim

Automatically dims your Mac's screen after 60 seconds of inactivity and restores brightness when you return.

## Requirements

Install these with Homebrew:
```bash
brew install brightness bc
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/MuntasirMalek/mac-auto-dim.git
cd mac-auto-dim
```

2. Install the files:
```bash
# First, remove any existing installation
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
rm -f ~/bin/auto_dim.sh ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness

# Create directories
mkdir -p ~/bin
mkdir -p ~/Library/LaunchAgents

# Copy and set permissions for the script
cp bin/auto_dim.sh ~/bin/
chmod 755 ~/bin/auto_dim.sh

# Copy LaunchAgent and replace ${USER} with your username
cp LaunchAgents/com.user.auto_dim.plist ~/Library/LaunchAgents/
sed -i '' "s/\${USER}/$(whoami)/g" ~/Library/LaunchAgents/com.user.auto_dim.plist
chmod 644 ~/Library/LaunchAgents/com.user.auto_dim.plist
```

3. Start the auto-dim service:
```bash
launchctl load ~/Library/LaunchAgents/com.user.auto_dim.plist
```

4. Verify it's running:
```bash
launchctl list | grep com.user.auto_dim
```
You should see something like: `XXXX 0 com.user.auto_dim` where XXXX is a number.

That's it! Your screen will now automatically dim after 60 seconds of inactivity.

## Uninstall

To remove auto-dim:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist
rm -f ~/bin/auto_dim.sh ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
```

## How it Works

- The script checks for system idle time every 5 seconds
- If the system has been idle for more than 60 seconds, it saves the current brightness level and dims the screen
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