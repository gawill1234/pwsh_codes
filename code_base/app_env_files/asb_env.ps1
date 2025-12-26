
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-ASB"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-ASB"

# git config --global --add safe.directory D:/AutoDeploy/Apps/-ASB

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\ASB.Api\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\ASB.Api"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\ESB"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\ASB\" + $whichcfg

$AppPoolName = "ESB"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
