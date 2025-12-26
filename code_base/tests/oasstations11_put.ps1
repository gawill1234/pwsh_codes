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

$tname = "oasstations11_put.ps1"

. ../lib/appstatus.ps1
. ./user_config.ps1

$newCode = '{
  "Station": {
    "Id": 0,
    "StationCode": "deadbeef_put"
  }
}'

#
#   For the moment, every target has this stationId
#   as a disabled item.  But put can still update it.
#   Probably a bug, but taking advantage of it for
#   the moment.
#
$stationId = 3010
Write-Host $newCode -f DarkRed

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
$fulluri = Add_route -uri $myuri -routeId 44 -query $stationId

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"
$headers = build_headers -headers $headers -key "Accept" -value "application/json"

$Response = run_uri_put -uri $fulluri -headers $headers -body $newCode

#
#   Process the result to determine pass or fail.
#   This is very simple processing.
#   exit status is meaningful.  exit 0 is a passing result.
#   Any non-zero exit status indicates a failure.
#   Within powershell, exit 0 will be "True".  Anything
#   else will be "False".
#

if ($dump -eq "yes") {
   try {
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json -Depth 9)
   } catch {
      Write-Host $Response
   }
}

Write-Host "PUT, URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.StationCode -eq "deadbeef_put") {
      Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Failed " -f Red
exit 1
