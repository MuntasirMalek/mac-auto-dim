# Mac Auto-Dim

Automatically dims your Mac's screen after a period of inactivity and restores brightness when you return.

## Requirements

Install these with Homebrew:
```bash
brew install brightness bc
```

## Quick Installation (1-Minute Default)

Run this single command in your Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/MuntasirMalek/mac-auto-dim/main/install.sh | bash
```

That's it! Your screen will now automatically dim after 1 minute of inactivity.

## Easy Configuration

Auto-dim includes a user-friendly configuration tool. You can run it in two ways:

### Interactive Menu

Simply run:
```bash
auto-dim
```

This brings up a simple menu where you can:
- Change the idle time before dimming
- Start or stop the auto-dim service
- View current settings

### Command Line

Quick commands for common actions:

```bash
# Set idle time to any number of seconds
auto-dim --time SECONDS
auto-dim --time 30 #Example for 30 seconds

# Turn auto-dim on
auto-dim --start

# Turn auto-dim off
auto-dim --stop

# Show current settings
auto-dim --status

# Show help
auto-dim --help
```

## Uninstall

The easiest way to uninstall is to just use:
```bash
auto-dim --stop
sudo rm -f /usr/local/bin/auto-dim
rm -f ~/bin/auto_dim.sh ~/bin/configure.sh ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
```

If you encounter any issues stopping the service, try these alternative methods:
```bash
# Alternative 1: Use the remove command
launchctl remove com.user.auto_dim

# Alternative 2: Kill the process directly
pkill -f auto_dim.sh

# Then remove the files
sudo rm -f /usr/local/bin/auto-dim
rm -f ~/bin/auto_dim.sh ~/bin/configure.sh ~/Library/LaunchAgents/com.user.auto_dim.plist ~/.prev_brightness
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

3. If you get "Input/output error" when trying to unload the service:
   - This is a common issue on newer macOS versions
   - Use `launchctl remove com.user.auto_dim` instead
   - Or stop using the configuration tool: `auto-dim --stop`

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements!

## License

MIT License - Feel free to use and modify as needed! 