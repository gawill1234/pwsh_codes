

$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-EBSAdmin"

if ($MAINROOT -eq $null -or $MAINROOT -eq "") {
   $MAINROOT = "D:\AutoDeploy"
}

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = $MAINROOT + "\Apps"
}

if ($COMPROOT -eq $null -or $COMPROOT -eq "") {
   $COMPROOT = $MAINROOT + "\AppComponents"
}

$DefaultPath = $APPROOT + "\-EBSAdmin"

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$TARGET = $COMPROOT + "\-EBSAdmin\ClientApp"
$MYLINK = $PathBase + "\ClientApp"

checkandcopycomponents -target $TARGET\node_modules -link $MYLINK\node_modules

$PublishLocation = "\bin\Release\net8.0\publish"
$PublishProfile = "FolderProfile"
$ProjectLocation = ""

$PublishPath = $PathBase + $PublishLocation
$ProjectPath = $PathBase + $ProjectLocation

Write-Host $PublishPath -f Magenta
Write-Host $ProjectPath -f Magenta

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\EBSAdmin"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\EBSAdmin\" + $whichcfg

$AppPoolName = "EBSAdmin"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
