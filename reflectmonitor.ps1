#Monitors Marium Reflect backups created with Macrium Site Manager
#You need to create a settings.json file from settings.json.example in the same directory as this script
#As some modules need to be installed, do the first run from console
#But first run 'Set-ExecutionPolicy RemoteSigned'
$ErrorActionPreference = 'Stop'
#add the API Module for healthchecks.io (https://www.powershellgallery.com/packages/PS.HealthChecks/1.0.3)
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

$Pwd = ConvertTo-SecureString -String $Settings.repopw -AsPlainText -Force
$Cred = [System.Management.Automation.PSCredential]::New($Settings.repouser, $pwd)
New-PSDrive -Name "repo" -PSProvider "FileSystem" -Root $Settings.repo -Credential $Cred

#does $repo exist
if (-not (Test-Path -Path repo:)) {
    throw [System.IO.DirectoryNotFoundException] "$($Settings.repo) not found."
}

#connect to healthcheck.io
Connect-HealthCheck -ApiKey $Settings.apikey

#scan subdirectories in $repo
Get-ChildItem -Directory repo: | ForEach-Object {
    #initialise $PingURL
    $PingURL = ""
    $backupdirectory = $_.Name
    $backupdirectory
    #create a tag (and name) for the check
    $check = $Settings.repotag + " " + $backupdirectory + " " + $Settings.additionaltags
    #check if a check for this computer already exists and get the PingURL
    Get-HealthCheck | Where-Object { $_.Tag -eq $check }|ForEach-Object {
        $PingURL = $_.PingURL.AbsoluteUri
        #if not, create it
        if (-not $PingURL) {
            # $NewCheck = New-HealthCheck -Name "$check" -Tag "$check"
            $PingURL = $NewCheck.PingURL.AbsoluteUri
            }
        Write-Output "ls repo"    
        Get-ChildItem -Path repo:
        #check for backup files younger then MaxBackupAge (in hours) and Ping healthchecks.io
        Get-ChildItem -Path ($Setting.repo + "/" +  $backupdirectory + "/*.bak") | ForEach-Object {
            if (($_.LastWriteTime) -gt (Get-Date).AddHours(-$Settings.MaxBackupAge)) { 
                Write-Output "Sending Ping to $PingURL for check: $check." 
                Invoke-RestMethod $PingURL
            }
            else {
                Write-Output "$_ is to old"
            }
        }
    }
}

#cleanup
Remove-PSDrive repo