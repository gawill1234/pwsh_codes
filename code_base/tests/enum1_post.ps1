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

. ../lib/appstatus.ps1
. ./user_config.ps1

$tname = "enum1_post.ps1"

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
#$fulluri = Add_route -uri $myuri -route "/OAS/Categories"
$fulluri = Add_route -uri $myuri -routeId 95

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$headers = build_headers -headers $headers -key "$item" -value "$xoas"

$Value = '{
   Value: {
     "Id": 0,
     "Name": "ATestDidIt",
     "CategoryId": "378103b6-bfc4-f011-94af-001dd802aff8",
     "ParentId": 0,
     "Description": "This is a test.",
     "SolutionId": 0,
     "IsSystemEnum": false,
     "ActivationDate": "2025-12-11",
     "DeactivationDate": ""
   }
}'

$Response = run_uri_post -uri $fulluri -headers $headers -body $Value



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
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json)
   } catch {
      Write-Host $Response
   }
}

Write-Host "POST, URI:  $fulluri" -f magenta
Write-Host "Create an enum item/entry" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.Name -eq "ATestDidIt") {
      #
      #   Create the data file needed by enum2_del.ps1
      #
      $mine.result.Id | Out-File -FilePath .\enum2.dat
      Write-Host $tname":  ASB - /OAS/Enums on" $which":  Test Passed " -f Green
      exit 0
   }
}

try {
   $mine = ($Response | ConvertFrom-Json)
} catch {
   Write-Host $Response -f Red
}
Write-Host $mine.ResponseStatus.ErrorCode
Write-Host $tname":  ASB - /OAS/Enums on" $which":  Test Failed " -f Red
exit 1


