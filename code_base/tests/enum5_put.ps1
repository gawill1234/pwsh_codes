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

$tname = "enum5_put.ps1"

function GetNewValue {
   param ($Response, $dump = "")

   $mine = ($Response.Content | ConvertFrom-Json)
   $A = 0
   while ($A -lt $($mine.Result.Count)) {
      if ($mine.Result[$A].Name.Contains("ATestDidIt")) {
         # Write-Host "Found it"
         $squib = $mine.Result[$A]
         $A = $mine.Result.Count + 10
      }
      $A += 1
   }

   #
   #   Add a random number to the update to, almost,
   #   guarantee that we are changing the string we
   #   want to change to something different than it
   #   currently is.
   #
   $rval = Get-Random
   $CheckValue = "ATestDidIt - PUT - " + $rval

   $myID = $squib.Id
   $squib.Name = $CheckValue
   $squib = ($squib | ConvertTo-Json)

   $useit = '{
      "Id": 0, 
      "Value": ' +  $squib + '}'

   if ($dump -eq "yes") {
      Write-Host $useit -f DarkRed
   }

   return $useit
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

$useit = GetNewValue -Response $Response -dump $dump
if ($dump -eq "yes") {
   Write-Host $useit -f DarkYellow
}

$CheckValue = ($useit | ConvertFrom-Json).Value.Name
$myId = ($useit | ConvertFrom-Json).Value.Id

if ($dump -eq "yes") {
   Write-Host "Value to check: "$CheckValue
   Write-Host "Using this ID: "$myID
}

#
#   Build the PUT URI
#
$fulluri2 = Add_route -uri $myuri -routeId 95 -query $myID
#
#   Do the actual PUT
#
$Response = run_uri_put -uri $fulluri2 -headers $headers -body $useit
#
#   Geth the resulting entry to verify
#
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
     Write-Host ($Response2 | ConvertFrom-Json | ConvertTo-Json) -f magenta
   } catch {
     Write-Host $Response2 -f magenta
   }
}

Write-Host "PUT, URI:  $fulluri2" -f magenta
Write-Host "Update name using PUT" -f magenta
if ($Response2.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.Result.Name.Contains($CheckValue)) {
      Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Failed " -f Red
exit 1
