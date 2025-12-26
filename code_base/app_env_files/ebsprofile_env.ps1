

$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-EBSProfile"

if ($MAINROOT -eq $null -or $MAINROOT -eq "") {
   $MAINROOT = "D:\AutoDeploy"
}

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = $MAINROOT + "\Apps"
}

if ($COMPROOT -eq $null -or $COMPROOT -eq "") {
   $COMPROOT = $MAINROOT + "\AppComponents"
}

$DefaultPath = $APPROOT + "\-EBSProfile"

$inex = "Internal"
$usedotnet = 1

$PathBase = get_app_project_directory -default_path $DefaultPath
$success = doweclone -PathBase $PathBase -repo $repo
git config --global --add safe.directory $PathBase

$TARGET = $COMPROOT + "\-EBSProfile\ClientApp"
$MYLINK = $PathBase + "\ClientApp"

checkandcopycomponents -target $TARGET\node_modules -link $MYLINK\node_modules

$PublishLocation = "\bin\Release\net8.0\publish"
$ProjectLocation = ""

$PublishPath = $PathBase + $PublishLocation
$PublishProfile = "FileDeployment"
$ProjectPath = $PathBase + $ProjectLocation

$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\EBSProfile"

$RemotePath = get_project_directory -default_path "$RemotePath" -RemoteServer $RemoteServer -which 1

# $ConfigPath = $APPROOT + "\-eCMSConfigFiles"
. $ScriptPath\app_env_files\ecmsconfig_env.ps1

$ConfigAppPath = $ConfigPath + "\EBSProfile\" + $whichcfg

$AppPoolName = "EBSProfile"

$AppPoolName = get_application_pool -default_pool "$AppPoolName" -RemoteServer $RemoteServer
