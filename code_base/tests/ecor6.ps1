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

$tname = "ecor6.ps1"

. ../lib/appstatus.ps1

. ./user_config.ps1

if ($which -eq "beta") {
   $res = "VA245-16-C-0040"
   $userid = "91451"
} elseif ($which -eq "test") {
   $res = "VA245-16-C-0040"
   $userid = "91022"
} else {
   Write-Host $tname": User and result data not yet set for" $which -f Red
   Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  Test Failed " -f Red
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
#$fulluri = Add_route -uri $myuri -route "OAS/Ecor/User/Files" -query $userid
$fulluri = Add_route -uri $myuri -routeId 32 -query $userid

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

$Response = run_uri_b -uri $fulluri -headers $headers


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

Write-Host "URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result[0].ContractPONumber -eq "$res") {
      Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  Test Passed " -f Green
      exit 0
   } else {
      if ($mine.result[0] -eq $null) {
         Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  The request succeeded" -f Green
         Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  but the result is empty" -f Green
         Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  Test Passed " -f Green
         exit 0
      }
   }
}

Write-Host $Response
Write-Host $tname": ASB - OAS/ECOR/User/Files on" $which":  Test Failed " -f Red
exit 1


