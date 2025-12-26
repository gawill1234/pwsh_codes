

$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-eCOR"

if ($MAINROOT -eq $null -or $MAINROOT -eq "") {
   $MAINROOT = "D:\AutoDeploy"
}

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = $MAINROOT + "\Apps"
}

if ($COMPROOT -eq $null -or $COMPROOT -eq "") {
   $COMPROOT = $MAINROOT + "\AppComponents"
}

$DefaultPath = $APPROOT + "\-eCOR"

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$TARGET = $COMPROOT + "\-eCOR\src\cor-home"
$MYLINK = $PathBase + "\src\cor-home"

checkandcopycomponents -target $TARGET\bower_components -link $MYLINK\bower_components
checkandcopycomponents -target $TARGET\node_modules -link $MYLINK\node_modules

$PublishLocation = "\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = "\src\ecor\ecor"

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\eCOR\" + $whichcfg

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\eCOR"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

$AppPoolName = "eCOR"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
