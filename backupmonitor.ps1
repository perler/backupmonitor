#checks backup $repo for files for $device with current date
#the script expects the (backup-) files in a subdirectory named for the device inside the repo directory
#when found pings $healthchecks_url
#run close to midnight

#enter details
$repo = "d:\repo"
$device = "workstation"
$healthchecks_url= "https://hc-ping.com/12712de1-b213-43e1-aws3-6c7e2da11fc8"

#script
if( Get-ChildItem -Path $repo\$device  | where {([datetime]::now.Date -eq $_.lastwritetime.Date)})
{
    Invoke-RestMethod $healthchecks_url
}

