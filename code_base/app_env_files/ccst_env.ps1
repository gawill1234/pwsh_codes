

$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-CCST"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-CCST"

$inex = "External"
$usedotnet = 0

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\src\CCST\CCST\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\CCST"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\NAC"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\CCST\" + $whichcfg

$AppPoolName = "NAC"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer

