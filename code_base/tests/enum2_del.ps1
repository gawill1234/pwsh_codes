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

$tname = "enumb2_del.ps1"

#
#   Get the Id created by ecor9.ps1
#
if (Test-Path -Path ".\enum2.dat") {
   $dumpId = Get-Content -Path ".\enum2.dat"
} else {
   Write-Host $tname": Id input file not found (enum2.dat)" -f Red
   Write-Host $tname": Run enum1_post.ps1 to create the file" -f Red
   Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Failed " -f Red
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
$fulluri = Add_route -uri $myuri -routeId 95 -query $dumpId

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
}

Write-Host "DELETE, URI:  $fulluri" -f magenta
Write-Host $tname": Delete Item" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.RemovedCount -eq 0) {
      $Response2 = run_uri_b -uri $fulluri -headers $headers
      if ($Response2.StatusCode -eq 200) {
         $mine2 = ($Response2.Content | ConvertFrom-Json)
         Write-Host $tname": ASB - /OAS/Enums, " $mine2.Result.Id -f Red
         if ($mine2.Result | Get-Member -Name "DeactivationDate") {
            if (Test-Path -Path ".\enum2.dat") {
               Remove-Item ".\enum2.dat" -Force
            }
            Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Passed " -f Green
            exit 0
         } else {
            Write-Host $tname": ASB - /OAS/Enums Group record still exists" -f Red
         }
      }
   }
}

Write-Host $Response
Write-Host $tname": ASB - /OAS/Enums on" $which":  Test Failed " -f Red
exit 1
