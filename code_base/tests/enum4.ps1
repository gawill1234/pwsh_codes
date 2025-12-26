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

$tname = "enum4.ps1"

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Vendor query.
#
$fulluri = Add_route -uri $myuri -routeId 95

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
   try {
     Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json) -f magenta
   } catch {
     Write-Host $Response -f magenta
   }
}

Write-Host "GET, URI:  $fulluri" -f magenta
Write-Host "Get ALL enums" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.Result[2].Name.Contains("Training")) {
      Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Failed " -f Red
exit 1
