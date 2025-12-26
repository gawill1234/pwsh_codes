#! pwsh
#
param ($which = "alpha",
       $ecode = "",
       $dump = "")

function findOurRoot {

   # $xx = (Get-Location).Path
   $xx = $PSScriptRoot

   if ($xx.EndsWith("Deploy")) {
      return $xx
   } else {
      if ($xx.Contains("Deploy")) {
         do {
            $xx = Split-Path $xx -Parent
         } until ($xx.EndsWith("Deploy"))
         return $xx
      }
   }

   return "NotFound"
}

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
#   https://vaww.dev.ecms.va.gov/esb/api/eCMSVersion.v17-01

#

$ScriptPath = findOurRoot

. $ScriptPath/lib/appstatus.ps1

#
#   We are going to run as the standard swagger user
#
$runas = "force"

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb"

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
#$fulluri = Add_route -uri $myuri -route "ErrorCodeList"
$fulluri = Add_route -uri $myuri -routeId 85

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
$headers = auth_header -runas "swagger"
$Response = run_uri_b -uri $fulluri -headers $headers


#
#   Process the result to determine pass or fail.
#   This is very simple processing.
#   exit status is meaningful.  exit 0 is a passing result.
#   Any non-zero exit status indicates a failure.
#   Within powershell, exit 0 will be "True".  Anything
#   else will be "False".
#

Write-Host "URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json | ConvertTo-Json)
   Write-Host $mine
   Write-Host "ASB - /ErrorCodeList on" $which":  Complete " -f Red
exit 0
} else {
   Write-Host $Response
   Write-Host "ASB - /ErrorCodeList on" $which":  Query Failed " -f Red
}

exit 1
