
git config --global --add safe.directory D:/AutoDeploy/Apps/-EBSProfile

$ProjectPath = "D:\AutoDeploy\Apps\GoggleTest"
$PublishPath = "D:\AutoDeploy\Apps\GoggleTest\bin\Release\net8.0\publish"

# $RemoteServer = "vac20appaes800.va.gov"  # Change to your VM name
$RemotePath = "\\$RemoteServer\d$\inetpub\wwwroot\Zeta_GW2"

$ConfigPath = "D:\AutoDeploy\Apps\-eCMSConfigFiles"
$ConfigAppPath = "D:\AutoDeploy\Apps\-eCMSConfigFiles\EBSProfile\" + $whichcfg

# $AppPoolName = "Zeta_JA_eCOR"
$AppPoolName = "Zeta_GW2"
