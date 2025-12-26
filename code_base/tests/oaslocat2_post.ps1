#! pwsh
#
param ($which = "alpha",
       $isEntra = "yes",
       $runas = "swagger",
       $port = "",
       $dump = "")

#
#   For the moment, this MUST be run from ths "test" directory.
#   I makes no effort to "find" itself in the file system.
#

$tname = "oaslocat2_post.ps1"

. ../lib/appstatus.ps1
. ./user_config.ps1

#
#   StateId(1225) is either Massachusetts or Louisiana.
#   It is used for both in the location stuff.
#
$newLoc = '{
  "Location": {
    "Id": 0,
    "Address1": "75 Chestnut St.",
    "Address2": "",
    "City": "Lee",
    "StateId": 1225,
    "PostalCode": "01238"
  }
}'

if ($dump -eq "yes") {
   Write-Host "POSTing this json" -f DarkRed
   Write-Host $newLoc -f DarkRed
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
$fulluri = Add_route -uri $myuri -routeId 52

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"
$headers = build_headers -headers $headers -key "Accept" -value "application/json"

$Response = run_uri_post -uri $fulluri -headers $headers -body $newLoc


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

Write-Host "POST, URI:  $fulluri" -f magenta
Write-Host "Create a locationg entry" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.City -eq "Lee") {
      $mine.result.Id | Out-File -FilePath .\oaslocat3.dat
      Write-Host $tname": On this server, you must run oaslocat3_del.ps1 or the" -f magenta
      Write-Host $tname": next run of this test on this server may fail." -f magenta
      Write-Host $tname": ASB - /OAS/Locations on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Locations on" $which":  Test Failed " -f Red
exit 1


