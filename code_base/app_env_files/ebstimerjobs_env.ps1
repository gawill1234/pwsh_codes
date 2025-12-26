
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-EBSTimerJobs"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-EBSTimerJobs"

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\EBSTimerJobs\EBSTimerJobs\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\EBSTimerJobs\EBSTimerJobs"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\_devZeta\wwwroot\JA\EBSTimerJobs"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\EBSTimerJobs\" + $whichcfg

$AppPoolName = "EBSTimerJobs"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
