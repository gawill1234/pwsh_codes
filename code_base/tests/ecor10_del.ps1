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

$tname = "ecor10_del.ps1"

$queryId = 10822

$stuff = '{
   "Justification": "ecor10.ps1 removal"
}'

#
#   Get the Id created by ecor9.ps1
#
if (Test-Path -Path ".\ecor10.dat") {
   $dumpId = Get-Content -Path ".\ecor10.dat"
} else {
   Write-Host $tname": Id input file not found (ecor10.dat)" -f Red
   Write-Host $tname": Run ecor9_post.ps1 to create the file" -f Red
   Write-Host $tname": ASB - OAS/ECOR/Files/Users on" $which":  Test Failed " -f Red
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
#$fulluri = Add_route -uri $myuri -route "OAS/Ecor/Files/Users" -query $queryId -query2 $dumpId
$fulluri = Add_route -uri $myuri -routeId 34 -query $queryId -query2 $dumpId

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

$Response = run_uri_delete -uri $fulluri -headers $headers -body $stuff


#
#   Process the result to determine pass or fail.
#   This is very simple processing.
#   exit status is meaningful.  exit 0 is a passing result.
#   Any non-zero exit status indicates a failure.
#   Within powershell, exit 0 will be "True".  Anything
#   else will be "False".
#

if ($dump -eq "yes") {
   Write-Host $Response -f magenta
   Write-Host $stuff -f magenta
}

Write-Host "DELETE, URI:  $fulluri" -f magenta
Write-Host $tname": Delete Item" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.RemovedCount -eq 0) {
      Remove-Item ".\ecor10.dat" -Force
      Write-Host $tname": ASB - OAS/ECOR/Files/Users on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - OAS/ECOR/Files/Users on" $which":  Test Failed " -f Red
exit 1


