$ErrorActionPreference = 'Stop'
#add the API MOdule for healthchecks.io (https://www.powershellgallery.com/packages/PS.HealthChecks/1.0.3)
Install-Module -Name PS.HealthChecks

#read .env
$Settings = Get-Content -Path $PSScriptRoot/settings.json | ConvertFrom-Json

#debug, varibles:
Write-Host "Our variables:"
Write-Host "=============="
$Settings.repo
$Settings.repotag
$Settings.apikey
$Settings.MaxBackupAge
Write-Host "=============="

#check $variables
#does $repo exist
if (-not (Test-Path -Path $Settings.repo)) {
    throw [System.IO.DirectoryNotFoundException] "$($Settings.repo) not found."
}

#connect to healthcheck.io
Connect-HealthCheck -ApiKey $Settings.apikey

#scan subdirectories in $repo
Get-ChildItem -Directory $Settings.repo | ForEach-Object {
    #initialise $PingURL
    $PingURL = ""
    $backupdirectory = $_.Name
    #create a tag (and name) for the check
    $check = $Settings.repotag + " " + $backupdirectory
    #check if a check for this computer already exists and get the PingURL
    Get-HealthCheck | Where-Object { $_.Tag -eq $check }|ForEach-Object {
        $PingURL = $_.PingURL.AbsoluteUri
        #if not, create it
        if (-not $PingURL) {
            # $NewCheck = New-HealthCheck -Name "$check" -Tag "$check"
            $PingURL = $NewCheck.PingURL.AbsoluteUri
            }
        #check for backup files younger then MaxBackupAge (in hours) and Ping healthchecks.io
        Get-ChildItem -Path ($Settings.repo + "/" +  $backupdirectory + "/*.bak") | ForEach-Object {
            if (($_.LastWriteTime) -gt (Get-Date).AddHours(-$Settings.MaxBackupAge)) { 
                Write-Output "Sending Ping to $PingURL for check: $check." 
                Invoke-RestMethod $PingURL
            }
        }
    }
}