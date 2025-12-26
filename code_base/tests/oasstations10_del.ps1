#! pwsh
#
param ($which = "alpha",
       $isEntra = "yes",
       $runas = "si",
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
#

. ../lib/appstatus.ps1

. ./user_config.ps1

$tname = "oasstations10_del.ps1"

$newCode = '{
  "Station": {
    "Id": 0,
    "StationCode": "deadbeef"
  }
}'

#
#   Get the Id created by ecor9.ps1
#
if (Test-Path -Path ".\oasstations10.dat") {
   $dumpId = Get-Content -Path ".\oasstations10.dat"
} else {
   Write-Host $tname": Id input file not found (oasstations10.dat)" -f Red
   Write-Host $tname": Run oasstations9_post.ps1 to create the file" -f Red
   Write-Host $tname": ASB - OAS/Stations on" $which":  Test Failed " -f Red
   exit 1
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
$fulluri = Add_route -uri $myuri -routeId 44 -query $dumpId

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
if ($isEntra -eq "both") {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
   $headers = build_headers -headers $headers -key "$item2" -value "$xoas2"
} else {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
}

$Response = run_uri_delete -uri $fulluri -headers $headers


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
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json -Depth 9) -f magenta
   } catch {
      Write-Host $Response -f magenta
   }
   Write-Host $stuff -f magenta
}

Write-Host "DELETE, URI:  $fulluri" -f magenta
Write-Host $tname": Delete Item" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.RemovedCount -eq 0) {
      if (Test-Path -Path ".\oasstations10.dat") {
         Remove-Item ".\oasstations10.dat" -Force
         Write-Host "Turn deleted item into deadbeef, this is normal for this test." -f magenta
         $Response = run_uri_put -uri $fulluri -headers $headers -body $newCode
      }
      Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Stations on" $which":  Test Failed " -f Red
exit 1


