$ErrorActionPreference = 'Stop'
#read .env
$Settings = Get-Content -Path $PSScriptRoot/settings.json | ConvertFrom-Json

#debug, varibles:
    Write-Host "Our variables:"
    Write-Host "=============="
    $Settings.repo
    $Settings.repotag
    $Settings.apikey

    #check $variables
    #does $repo exist
if (! (Test-Path -Path $Settings.repo)) {
    throw (New-Object System.IO.DirectoryNotFoundException("REPO Directory not found:" + dirEx.Message, $Settings.repo))
}
    #does $APIkey work

#ls $repo
    #for each subdir
        #check if hc probe exist
            #if yes put URL in $currentprobe
            #if no
                #create probe
                #put URL in $currentprobe
        #list $subdir\*\files
            #for each file
            #if filedate is younger than 1 day
                #call $currentprobe
    #endfor# 
