#read .env
$Settings = Get-Content -Path $PSScriptRoot/settings.json | ConvertFrom-Json

#debug, varibles:
Write-Host "Our variables:"
Write-Host "=============="
$Settings.repo
$Settings.repotag
$Settings.apikey
$Settings.MaxBackupAge
$Setting.repouser
$Setting.repopassword
Write-Host "=============="

$Pwd = ConvertTo-SecureString -String $Settings.repopassword -AsPlainText -Force
$Cred = [System.Management.Automation.PSCredential]::New($Settings.repouser, $pwd)
New-PSDrive -Name "repo" -PSProvider "FileSystem" -Root $Settings.repo -Credential $Cred

#does $repo exist
if (-not (Test-Path -Path repo:)) {
    throw [System.IO.DirectoryNotFoundException] "$($Settings.repo) not found."
}

Remove-PSDrive repo