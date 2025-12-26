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

$tname = "ecor9_post.ps1"

$queryId = 10822
$stuff = '{
   "RoleId": 25,
   "User": {
      "Id": 0,
      "Email": "gary.williams1@va.gov",
      "Name": "Gary Williams",
      "Archived": false,
      "DeactivationDate": "2026-11-22",
      "PhoneNumber": "7249919403"
   },
   "Justification": "ecor9.ps1 addition"
}'

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
#$fulluri = Add_route -uri $myuri -route "OAS/Ecor/Files/Users" -query $queryId
$fulluri = Add_route -uri $myuri -routeId 34 -query $queryId

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

$Response = run_uri_post -uri $fulluri -headers $headers -body $stuff


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
   Write-Host $stuff -f magenta
}

Write-Host "POST, URI:  $fulluri" -f magenta
Write-HOst $tname": Create Item" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.User.Email -eq "Gary.Williams1@va.gov") {
      Write-Host $tname": ASB - OAS/ECOR/Files/Users id: " $mine.result.Id -f Green
      #
      #   Create the data file needed by ecor10_del.ps1
      #
      $mine.result.Id | Out-File -FilePath .\ecor10.dat
      Write-Host $tname": ASB - OAS/ECOR/Files/Users on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - OAS/ECOR/Files/Users on" $which":  Test Failed " -f Red
exit 1


