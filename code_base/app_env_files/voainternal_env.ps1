
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-VOAInternal"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-VOAInternal"

$inex = "Internal"
$usedotnet = 0

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$PublishLocation = "\VOAAdmin35.3\bin\app.publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\VOAAdmin35.3"
$ProjectFile = "\VOAAdmin.vbproj"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta
Write-Host $RemoteServer -f Magenta

#
#   On some servers, the path is SIP
#   On others it is SIP_Admin
#
# $RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\SIP"
$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\SIP_Admin"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\VOAInternal\" + $whichcfg

$AppPoolName = "VOA_Admin"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer "$RemoteServer"

