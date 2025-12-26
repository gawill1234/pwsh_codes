
$repo = "https://devops.ec.va.gov/SharedServices/eCMS/_git/-eCMSConfigFiles"

if ($APPROOT -eq $null -or $APPROOT -eq "") {
   $APPROOT = "D:\AutoDeploy\Apps"
}

$DefaultPath = $APPROOT + "\-eCMSConfigFiles"

$ConfigPath = $DefaultPath
