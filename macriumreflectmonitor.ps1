# macrium reflect (with site manager) stores backups inside the repo in a
# directory based on the disk UUID like 
# d:\repo\workstatin\{0A10DB4D-9FE8-4D9B-A57C-9BA65A28196B}\53AFD3B70689C5CF-00-00.mrimg
# so we check recursively below the device name inside the repo for files with the current date

# repo location
$repo = "d:\repo"

# read .env file with workstations and healthchecks URLs and check each for backups
Import-Csv -Path '.env' -Delimiter =  -Header 'device', 'healthchecks_url' | ForEach-Object {
    $device = $($_.device)
    $healthchecks_url = $($_.healthchecks_url)

    if( Get-ChildItem -Path $repo\$device -Recurse  | where {([datetime]::now.Date -eq $_.lastwritetime.Date)})
    {
        Invoke-RestMethod $healthchecks_url
    }
 }
