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
#   It is here as a crude example of running a route/api test
#   without using swagger or selenium.  Since ASB is, for 
#   all intents and purposes, a service, it is treated as such.
#   That means the URI is sent to ASB in a similar way to what
#   swagger would do.  The pass/fail processing here is very
#   simple and would need to have json result processing added.
#   With that, it would be possible pick out individual json
#   sections (status, result count, text) to further ensure that
#   the test did actually pass.
#

$tname = "oasstations9_post.ps1"

. ../lib/appstatus.ps1
. ./user_config.ps1

$newCode = '{
  "Station": {
    "Id": 0,
    "StationCode": "calvinandhobbes"
  }
}'

if ($dump -eq "yes") {
   Write-Host "POSTing this json" -f DarkRed
   Write-Host $newCode -f DarkRed
}

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
#$fulluri = Add_route -uri $myuri -route "OAS/Stations/Locations" -query 90909
$fulluri = Add_route -uri $myuri -routeId 44

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"
$headers = build_headers -headers $headers -key "Accept" -value "application/json"

$Response = run_uri_post -uri $fulluri -headers $headers -body $newCode


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

Write-Host "POST, URI:  $fulluri" -f magenta
Write-Host "Create a station code" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.StationCode -eq "calvinandhobbes") {
      $mine.result.Id | Out-File -FilePath .\oasstations10.dat
      Write-Host $tname": On this server, you must run oasstations10_del.ps1 or the" -f magenta
      Write-Host $tname": next run of this test on this server will fail." -f magenta
      Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Failed " -f Red
exit 1


