# Windows Network Tools

## reset-network-drivers.bat

**Run as Administrator** (right-click → Run as administrator).

What it does:
1. Resets Winsock and the TCP/IP stack
2. Flushes DNS and renews the IP address
3. Disables + re-enables all network adapters (reloads drivers)
4. Restarts DHCP and DNS Client services

After it finishes, restart your PC for the changes to fully apply.

> The aggressive `netcfg -d` line is commented out by default — it removes
> ALL network adapters and settings. Only uncomment it if the normal reset
> did not work.

## License

MIT — see [LICENSE](LICENSE).
