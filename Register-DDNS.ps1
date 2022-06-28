<#
    .SYNOPSIS
    Dynamic DNS (DDNS) updater for Windows Task Scheduler
    
    .DESCRIPTION
    Create a task in the Windows Scheduler to automatically invokes a web request to Dynamic DNS URL and updates the DNS Zone record when network state change.
    Compatible with any DDNS service exposing URL update interface.
    
    .EXAMPLE
    .\Register-DDNS https://v6.sync.afraid.org/u/AbCdEfGhIjKlMnOpQrStUvWxYz0123456789/

    .EXAMPLE
    & "$PSScriptRoot\Register-DDNS" https://v6.sync.afraid.org/u/AbCdEfGhIjKlMnOpQrStUvWxYz0123456789/
    You can create a one-line script file in the same directory to preserve URL.
    
#>
param (
    [Parameter(Mandatory=$True)][string]$Url
)

Write-Host "Checking for elevated permissions..."

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to run this script. Requesting elevated right ..."
    Start-Process -FilePath PowerShell "& {Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned; . '$PSCommandPath' $Url}" -Verb runAs
    exit
} else {
    Write-Host "Code is running as administrator - go on executing the script..." -ForegroundColor Green
}

$taskName = 'Update-DDNS'

$pScheduledTaskAction = @{
    Execute  = 'PowerShell'
    Argument = "-Command ""& {Invoke-WebRequest $Url}"""
}

$eventLog = 'Microsoft-Windows-NetworkProfile/Operational'
$eventSource = 'Microsoft-Windows-NetworkProfile'
$eventId = '4004'

$pScheduledTask = @{
    TaskName    = $taskName
    TaskPath    = '\'
    Action      = New-ScheduledTaskAction @pScheduledTaskAction
    Principal   = New-ScheduledTaskPrincipal -UserId 'SYSTEM'
    Settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
    Trigger  =  @(
        (Get-CimClass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly -Property @{
            Enabled = $True
            Subscription = "<QueryList><Query Id='0' Path=""$eventLog""><Select Path=""$eventLog"">*[System[Provider[@Name='$eventSource'] and EventID=$eventId]]</Select></Query></QueryList>"
        })
    )
}

if ($(Get-ScheduledTask).TaskName -eq $taskName) {
    Set-ScheduledTask @pScheduledTask
} else {
    Register-ScheduledTask @pScheduledTask
}
