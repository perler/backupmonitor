#Monitors Marium Reflect backups created with Macrium Site Manager
#You need to create a settings.json file from settings.json.example in the same directory as this script
#As some modules need to be installed, do the first run from console
#But first run 'Set-ExecutionPolicy RemoteSigned'
$ErrorActionPreference = 'Stop'
#add the API Module for healthchecks.io (https://www.powershellgallery.com/packages/PS.HealthChecks/1.0.3)
Install-Module -Name PS.HealthChecks
#read .env
$Settings = Get-Content -Path $PSScriptRoot/settings.json | ConvertFrom-Json
#ask for name of installation and put into $Settings as repo and write into settings.json
$Settings.repo = Read-Host "Please enter the name of the installation"
$Settings | ConvertTo-Json | Set-Content -Path $PSScriptRoot/settings.json



#read c:\ProgramData\Macrium\SiteManager\repositories.xml and get the repository path
$repositoryPath = (Select-Xml -Path "C:\ProgramData\Macrium\SiteManager\repositories.xml" -XPath "//repositories/repository/path").Node.InnerText
##checks
#check that $repositoryPath exists
if (-not (Test-Path -Path $repositoryPath)) {
    throw [System.IO.DirectoryNotFoundException] "$($repositoryPath) not found."
}
#connect to healthcheck.io
Connect-HealthCheck -ApiKey $Settings.apikey
#scan subdirectories in $repositoryPath



