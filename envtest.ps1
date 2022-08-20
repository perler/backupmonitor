# read .env
$SettingsObject = Get-Content -Path $PSScriptRoot/settings.json | ConvertFrom-Json
$SettingsObject

$SettingsObject.repo