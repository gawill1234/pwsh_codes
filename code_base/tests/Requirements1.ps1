#! pwsh
#
param ($which = "alpha",
       $runas = "force",
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
# . ../lib/rt_table.ps1

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
#    Beta acceptable values
#    1,
#    1317349,
#    1321005,
#    1323349,
#    1326150,
#    1328779
#
if ($which -eq "alpha") {
   #$fulluri = Add_route -uri $myuri -route "Requirements" -query "1352071"
   $fulluri = Add_route -uri $myuri -routeId 77 -query "1352071"
   $answer = 1352071
} elseif ($which -eq "beta") {
   #$fulluri = Add_route -uri $myuri -route "Requirements" -query "1"
   $fulluri = Add_route -uri $myuri -routeId 77 -query "1"
   $answer = 1
} else {
   Write-Host "Need a number to look for in $which.  Not set yet." -f Red
   Write-Host "Possibly no FORCE items in $which db." -f Red
   #$fulluri = Add_route -uri $myuri -route "Requirements" -query "0"
   $fulluri = Add_route -uri $myuri -routeId 77 -query "0"
   $answer = $null
}

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
   try {
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json -Depth 9)
   } catch {
      Write-Host $Response
   }
}

Write-Host "URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($which -eq "charlie") {
      Write-Host "ASB - /Requirements on" $which":  Test Passed " -f Green
      Write-Host "  On charlie, we have no FORCE requirements data." -f Green
      Write-Host "  So an empty success is ok for passing; for now." -f Green
      exit 0
   } else {
      if ($mine.result.RequirementId -eq $answer) {
         Write-Host "ASB - /Requirements on" $which":  Test Passed " -f Green
         exit 0
      }
   }
}

Write-Host $Response
Write-Host "ASB - /Requirements on" $which":  Test Failed " -f Red
exit 1


