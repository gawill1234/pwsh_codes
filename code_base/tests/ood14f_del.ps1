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

$tname = "ood14f_del.ps1"

#
#   Get the Id created by ood14e_post.ps1
#
if (Test-Path -Path ".\ood14f.dat") {
   $dumpId = Get-Content -Path ".\ood14f.dat"
} else {
   Write-Host $tname": Id input file not found (ood14f.dat)" -f Red
   Write-Host $tname": Run ood14e_post.ps1 to create the file" -f Red
   Write-Host $tname": ASB - OAS/OOD/Groups on" $which":  Test Failed " -f Red
   exit 1
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
#$fulluri = Add_route -uri $myuri -route "OAS/OOD/Groups" -query $dumpId
$fulluri = Add_route -uri $myuri -routeId 15 -query $dumpId

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

$Response = run_uri_delete -uri $fulluri -headers $headers
if ($Response.StatusCode -eq 200) {
   $Response2 = run_uri_b -uri $fulluri -headers $headers
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
   Write-Host $Response -f magenta
   Write-Host $stuff -f magenta
}

$mine2 = $null
Write-Host "DELETE, URI:  $fulluri" -f magenta
Write-Host $tname": Delete Item from POST" -f magenta
if ($Response.StatusCode -eq 200) {
   if ($Response2.StatusCode -eq 200) {
      $mine2 = ($Response2.Content | ConvertFrom-Json)
   }
}

if ($mine2.Result | Get-Member -Name "DeactivationDate") {
   if (Test-Path -Path ".\ood14f.dat") {
      Remove-Item ".\ood14f.dat" -Force
   }
   Write-Host $tname": ASB - OAS/OOD/Groups on" $which":  Test Passed " -f Green
   exit 0
} else {
   Write-Host $tname": ASB - OAS/OOD/Groups, " $mine2.Result.Id -f Red
   Write-Host $tname": ASB - OAS/OOD/Groups Group record still exists" -f Red
}

Write-Host $Response
Write-Host $Response2
Write-Host $tname": ASB - OAS/OOD/Groups on" $which":  Test Failed " -f Red
exit 1
