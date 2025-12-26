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

if ($which -eq "beta") {
   $qry = 11784
} elseif ($which -eq "test") {
   $qry = 11000
} else {
   $qry = 11784
}

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
#$fulluri = Add_route -uri $myuri -route "UserRole"
$fulluri = Add_route -uri $myuri -routeId 90

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"

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
   if ($mine.result.Count -gt 1) {
      Write-Host "ASB - /UserRole on" $which":  Test Passed " -f Green
      exit 0
   } else {
      Write-Host "The result was empty but the query succeeded" -f Yellow
      Write-Host "ASB - /UserRole on" $which":  Test Passed " -f Green
      exit 0
   }
}

try {
   $mine = ($Response | ConvertFrom-Json)
} catch {
   Write-Host $Response -f Red
}
Write-Host $mine.ResponseStatus.ErrorCode
Write-Host "ASB - /UserRole on" $which":  Test Failed " -f Red
exit 1


