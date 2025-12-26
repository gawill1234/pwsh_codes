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

$tname = "search2.ps1"

$strlist = @("J", "Ja", "Jam", "James", "T", "Ta", "Tam", "Tamm", "Tammy")

. ../lib/appstatus.ps1

. ./user_config.ps1

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
if ($isEntra -eq "both") {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
   $headers = build_headers -headers $headers -key "$item2" -value "$xoas2"
} else {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
}

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   search query
#
$possible = 0
$correct = 0
foreach ($thing in $strlist) {
   #$fulluri = Add_route -uri $myuri -route "OAS/Search/Users" -query $thing
   $argSet = addArguments -newArgName "SearchValue" -newArgValue $thing 
   $fulluri = Add_route -uri $myuri -routeId 37 -query $argSet
   $Response = run_uri_b -uri $fulluri -headers $headers
   Write-Host "URI:  $fulluri" -f magenta
   if ($Response.StatusCode -eq 200) {

      $mine = ($Response.Content | ConvertFrom-Json)
      Write-Host "ASB - OAS/Search/Users search term: " $thing -f Green
      Write-Host "ASB - OAS/Search/Users count      : " $mine.Result.Count -f Green
      if ($mine.Result.Count -ge 1) {
         $locid = $mine.Result[0].Id
         $possible = $possible + 1
         if ($locid -ne "" -and $locid -ne $null) {
            $correct = $correct + 1
            Write-Host "ASB - OAS/Search/Users ID         : " $locid -f Green
         }
      }
      Write-Host "======================" -f Yellow
   }
}

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

if ($possible -gt 0) {
   if ($possible -eq $correct) {
      Write-Host $tname": ASB - OAS/Search/Users count verification passed" -f Green
      Write-Host $tname": ASB - OAS/Search/Users on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - OAS/Search/Users possible matches : $possible" -f Red
Write-Host $tname": ASB - OAS/Search/Users actual matches   : $correct" -f Red
Write-Host $tname": ASB - OAS/Search/Users on" $which":  Test Failed " -f Red
exit 1


