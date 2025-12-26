#! pwsh
#
param ($which = "alpha",
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
#   https://vaww.dev.alpha.ecms.va.gov/esb/api/Requirements.v17-01/1
#

. ../lib/appstatus.ps1

$tname = "ContractByProject1.ps1"

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
$argSet = addArguments -newArgName "StartDate" -newArgValue "2025-10-01"
$argSet = addArguments -sofar $argSet -newArgName "EndDate" -newArgValue "2025-10-30"
$argSet = addArguments -sofar $argSet -newArgName "ProjectNumber" -newArgValue "1"

#$fulluri = Add_route -uri $myuri -route "/Contracts/ByProject" -query $argSet
$fulluri = Add_route -uri $myuri -routeId 58 -query $argSet

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
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
   Write-Host ($Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 7)
   # Write-Host $Response
}

$loc = 3
if ($which -eq "beta") {
   $loc = 1
}

Write-Host "URI:  $fulluri" -f magenta
Write-Host $tname": Expected parameters" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.Projects.Count -gt 0) {
      if ($mine.result.Projects[0].ProjectNumber.Contains("1")) {
         Write-Host $tname": ASB - /Contracts/ByProject on" $which":  Test Passed " -f Green
         exit 0
      }
   }
}

# Write-Host $Response
Write-Host $tname": ASB - /Contracts/ByProject on" $which":  Test Failed " -f Red
exit 1


