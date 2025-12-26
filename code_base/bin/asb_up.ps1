param ($which = "alpha")

$username = "swagger-user"
$password = "DKS6f3BdZbZDWDxP"

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

if ($which -eq "alpha") {
   $URI = "https://vaww.dev.alpha.ecms.va.gov/esb/api/Vendors/VendorInfo.v21-01?VendorName=General%20Electric" 
} elseif ($which -eq "beta") {
   $URI = "https://vaww.dev.ecms.va.gov/esb/api/Vendors/VendorInfo.v21-01?VendorName=General%20Electric" 
} elseif ($which -eq "charlie") {
   $URI = "https://vaww.dev.ifams.ecms.va.gov/esb/api/Vendors/VendorInfo.v21-01?VendorName=General%20Electric" 
} elseif ($which -eq "test") {
   $URI = "https://vaww.test.ecms.va.gov/esb/api/Vendors/VendorInfo.v21-01?VendorName=General%20Electric" 
} else {
   Write-Host "Unknown server: $which" -f Red
   exit
}

$Response = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri "$URI" -UseBasicParsing

if ($Response.StatusCode -eq 200) {
   if ($Response.Content.Contains("GENERAL ELECTRIC")) {
      Write-Host "ASB on $which is up" -f Green
      exit
   }
}

Write-Host $Response
Write-Host "ASB on $which is down" -f Red
exit


