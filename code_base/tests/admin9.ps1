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
#   https://vaww.dev.alpha.ecms.va.gov/esb/api/Requirements.v17-01/1
#

. ../lib/appstatus.ps1

$tname = "admin9.ps1"

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
$argSet = addArguments -newArgName "FromDate" -newArgValue "10/1/2025"
#$fulluri = Add_route -uri $myuri -route "/Admin/Jobs/History" -query $argSet
$fulluri = Add_route -uri $myuri -routeId 7 -query $argSet

$argSet = addArguments -newArgName "FromDate" -newArgValue "2025-10-01"
#$fulluri2 = Add_route -uri $myuri -route "/Admin/Jobs/History" -query $argSet
$fulluri2 = Add_route -uri $myuri -routeId 7 -query $argSet

$ans = "APIs"
#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"

$Response = run_uri_b -uri $fulluri -headers $headers
$Response2 = run_uri_b -uri $fulluri2 -headers $headers


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

Write-Host "Compare result of: " -f magenta
Write-Host "URI:  $fulluri" -f magenta
Write-Host "URI:  $fulluri2" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   $mine2 = ($Response2.Content | ConvertFrom-Json)
   if ($mine.result[0] -ne $null) {
      if ($mine.result.Count -eq $mine2.result.Count) {
         if ($mine.result[0].JobGroup -eq $mine2.result[0].JobGroup) {
            Write-Host $tname": ASB - /Admin/Jobs/History (FromDate slash) on" $which":  Test Passed " -f Green
            exit 0
         } else {
            Write-Host $tname": ASB - /Admin/Jobs/History on" $which":  Group compare fail " -f Green
         }
      } else {
            Write-Host $tname": ASB - /Admin/Jobs/History on" $which":  Count compare fail " -f Green
            Write-Host $tname": ASB - /Admin/Jobs/History count:" $mine.result.Count -f Green
            Write-Host $tname": ASB - /Admin/Jobs/History count:" $mine2.result.Count -f Green
      }
   }
}

Write-Host $Response
Write-Host $tname": ASB - /Admin/Jobs/History (FromDate slash) on" $which":  Test Failed " -f Red
exit 1


