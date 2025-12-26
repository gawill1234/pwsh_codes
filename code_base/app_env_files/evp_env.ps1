
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-eVP"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-eVP"

$inex = "External"
$usedotnet = 0
$PublishProfile = "FileDeployment"

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\obj\Release\PublishFileSystem"
$ProjectLocation = ""

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\eVP"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\eVP\" + $whichcfg

$AppPoolName = "eVP"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
