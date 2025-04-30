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

2. Copy files to their locations:
```bash
# Create directories
mkdir -p ~/bin
mkdir -p ~/Library/LaunchAgents

# Copy and set permissions for the script
cp bin/auto_dim.sh ~/bin/
chmod 755 ~/bin/auto_dim.sh

# Copy and set permissions for the LaunchAgent
cp LaunchAgents/com.user.auto_dim.plist ~/Library/LaunchAgents/
chmod 644 ~/Library/LaunchAgents/com.user.auto_dim.plist
```

3. Start the auto-dim service:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.auto_dim.plist 2>/dev/null
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
rm ~/bin/auto_dim.sh ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
```

## How it Works

- The script checks for system idle time every 5 seconds
- If the system has been idle for more than 60 seconds, it saves the current brightness level and dims the screen
- When activity is detected, it restores the previous brightness level
- Logs are written to `~/Library/Logs/auto_dim.log`

## Troubleshooting

Check the log files for any issues:
- `~/Library/Logs/auto_dim.out.log` - Standard output
- `~/Library/Logs/auto_dim.err.log` - Error output

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements!

## License

MIT License - Feel free to use and modify as needed! 