
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-EpicWebService"

#
#   You can set your own APPROOT where you have repos
#
if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-EpicWebService"

$inex = "Internal"
$usedotnet = 0
$PublishProfile = "FileDeployment"

# $ProjectPath = $APPROOT + "\-EpicWebService"
# $PublishPath = $APPROOT + "\-EpicWebService\obj\Release\PublishFileDeployment"

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\obj\Release\PublishFileDeployment"
$ProjectLocation = ""

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

#
#   updateVersion is NOT in the Project path for this one.
#
#. $PublishPath\updateVersion.ps1

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\EpicWebService"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1
$ConfigAppPath = $ConfigPath + "\EpicWebService\" + $whichcfg

$AppPoolName = "EpicWebService"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta
Write-Host $ConfigPath -f Magenta
Write-Host $ConfigAppPath -f Magenta
Write-Host $AppPoolName -f Magenta

