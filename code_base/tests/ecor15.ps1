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

. ../lib/appstatus.ps1

. ./user_config.ps1

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
#   query can be 18177 for beta and test, just to be different.
#
if ($which -eq "beta") {
   $qry = 18177
} elseif ($which -eq "alpha") {
   $qry = 1079
} elseif ($which -eq "charlie") {
   $qry = 18177
} else {
   $qry = 1
}
#$fulluri = Add_route -uri $myuri -route "OAS/Ecor/Files/Tasks" -query $qry
$fulluri = Add_route -uri $myuri -routeId 33 -query $qry

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
   if ($mine.Result[0].ContractId -eq $qry) {
      Write-Host "ASB - OAS/ECOR/Files/{id}/Tasks on" $which":  Test Passed " -f Green
      exit 0
   }
   $mine2 = ($mine | ConvertTo-Json)
   Write-Host $mine2
}

Write-Host $Response
Write-Host "ASB - OAS/ECOR/Files/{id}/Tasks on" $which":  Test Failed " -f Red
exit 1


