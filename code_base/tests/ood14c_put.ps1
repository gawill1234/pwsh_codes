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

$tname = "ood14c_put.ps1"

$mydate = Get-Date -Format "yyyy-MM-dd mm"

$mydate = $mydate + " hello"

$stuff = '{
   "Group": {
      "Id": 0,
      "Title": "ood14c_put",
      "Description": "Test",
      "Reason": "'

$stuff = $stuff + $mydate + '",
      "Display": false
   }
}'

Write-Host $stuff -f DarkYellow

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
#$fulluri = Add_route -uri $myuri -route "OAS/OOD/Groups" -query 15
$fulluri = Add_route -uri $myuri -routeId 15 -query 15

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "Accept" -value "application/json"
if ($isEntra -eq "both") {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
   $headers = build_headers -headers $headers -key "$item2" -value "$xoas2"
} else {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
}

$Response = run_uri_put -uri $fulluri -headers $headers -body $stuff


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
   Write-Host "Body:  $stuff" -f magenta
}

Write-Host "PUT, URI:  $fulluri" -f magenta
Write-HOst $tname": Modify Item" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   Write-Host $mine.Result.DeactivationDate -f DarkYellow
   if ($mine.result.Reason -eq "$mydate") {
      Write-Host $tname": ASB - OAS/OOD/Groups id: " $mine.result.Id -f Green
      #
      #   Create the data file needed by ood14d_del.ps1
      #
      $mine.result.Id | Out-File -FilePath .\ood14d.dat
      Write-Host $tname": ASB - OAS/OOD/Groups on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - OAS/OOD/Groups on" $which":  Test Failed " -f Red
exit 1
