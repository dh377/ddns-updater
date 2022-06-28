### SYNOPSIS
Dynamic DNS (DDNS) updater for Windows Task Scheduler

### DESCRIPTION
Create a task in the Windows Scheduler to automatically invokes a web request to Dynamic DNS URL and updates the DNS Zone record when network state change.
Compatible with any DDNS service exposing URL update interface.

### EXAMPLE
* Just run Register-DDNS with DDNS URL to be updated
```powershell
.\Register-DDNS https://v6.sync.afraid.org/u/AbCdEfGhIjKlMnOpQrStUvWxYz0123456789/
```

* You can create a one-line script file in the same directory to preserve URL:
```powershell
& "$PSScriptRoot\Register-DDNS" https://v6.sync.afraid.org/u/AbCdEfGhIjKlMnOpQrStUvWxYz0123456789/
```
