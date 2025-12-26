

$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-JobScheduler"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-JobScheduler"

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\JobScheduler\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\JobScheduler"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\JobScheduler"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\JobScheduler\" + $whichcfg

#
#   Setting to "NoPool" means you are explicitly saying there
#   is no pool associated with this app.  This will cause all
#   pool start/stop functions to be bypassed.
#
$AppPoolName = "NoPool"

