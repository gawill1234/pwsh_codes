#! pwsh
#
param ($which = "alpha",
       $isEntra = "yes",
       $runas = "swagger",
       $port = "",
       $dump = "")

#
#   For the moment, this MUST be run from ths "test" directory.
#   I makes no effort to "find" itself in the file system.
#

$tname = "oaslocat2pt5_put.ps1"

. ../lib/appstatus.ps1
. ./user_config.ps1

if (Test-Path -Path ".\oaslocat3.dat") {
   $locId = Get-Content -Path ".\oaslocat3.dat"
} else {
   Write-Host $tname": Id input file not found (oaslocat3.dat)" -f Red
   Write-Host $tname": Run oaslocat2_post.ps1 to create the file" -f Red
   Write-Host $tname": DO NOT run oaslocat3_del.ps1 before this test" -f Red
   Write-Host $tname": as the data file will be deleted by that test" -f Red
   Write-Host $tname": ASB - OAS/Locations on" $which":  Test Failed " -f Red
   exit 1
}

$newLoc = '{
  "Id": 0,
  "Location": {
    "Id": ' + $locId + ',
    "Address1": "100 Carbunkle St.",
    "Address2": "",
    "City": "Lee",
    "StateId": 1225,
    "PostalCode": "01238"
  }
}'

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
$fulluri = Add_route -uri $myuri -routeId 52 -query $locId

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"
$headers = build_headers -headers $headers -key "Accept" -value "application/json"

$Response = run_uri_put -uri $fulluri -headers $headers -body $newLoc

#
#   Process the result to determine pass or fail.
#   This is very simple processing.
#   exit status is meaningful.  exit 0 is a passing result.
#   Any non-zero exit status indicates a failure.
#   Within powershell, exit 0 will be "True".  Anything
#   else will be "False".
#

if ($dump -eq "yes") {
   Write-Host $Response
}

Write-Host "PUT, URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.Address1 -eq "100 Carbunkle St.") {
      Write-Host $tname": ASB - /OAS/Locations on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Locations on" $which":  Test Failed " -f Red
exit 1
