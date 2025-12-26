#! pwsh
#
param ($which = "alpha",
       $isEntra="yes",
       $runas = "force",
       $port = "",
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
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
$fulluri = Add_route -uri $myuri -routeId 84

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
$Response = run_uri_b -uri $fulluri -headers $headers


#
#   Process the result to determine pass or fail.
#   This is very simple processing.
#   exit status is meaningful.  exit 0 is a passing result.
#   Any non-zero exit status indicates a failure.
#   Within powershell, exit 0 will be "True".  Anything
#   else will be "False".
#

#
#   This list is for doing the result check.  At least ONE of
#   these will be on one of the hosts this can point at.  So
#   later, just find any one of these and make sure the release
#   portion of the name contains this app term.
#
$poss_list = @("OOD", "FORCE", "eCOR", "ASB", "VOAInternal", "VOAExternal", "EBSAdmin", "EASAdmin", "EBSProfile", "EpicWebService", "VendorWebService")

$maxtries = $poss_list.Count

if ($dump -eq "yes") {
   try {
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json -Depth 9)
   } catch {
      Write-Host $Response
   }
}

Write-Host "URI:  $fulluri" -f magenta
if ($Response.StatusCode -eq 200) {
   # $mine = ($Response.Content | ConvertFrom-Json | ConvertTo-Json)
   $count = 0
   $mine = ($Response.Content | ConvertFrom-Json)
   do {
      $thing = $poss_list[$count]
      if ($isEntra -eq "yes") {
         $squirrel = $mine.Result.eCMSApplicationVersions.$thing
      } else {
         $squirrel = $mine.Result.$thing
      }
      $count = $count + 1
   } while ($squirrel -eq $null -and $count -lt $maxtries)
   if ($squirrel -ne $null) {
      $squirrel = $squirrel.ToLower()
      $thing = $thing.ToLower()
      if ($squirrel.Contains("$thing")) {
         Write-Host "ASB - /eCMSVersions on" $which":  Test Passed " -f Green
         exit 0
      }
   }
}

Write-Host $Response
Write-Host "Failure message:" -f yellow
Write-Host "   Does the target host have the new or old style of" -f Yellow
Write-Host "   eCMSVersions?  If it has the new style with the" -f Yellow
Write-Host "   eCMSApplicationVersions/ASBFeatureFlags groupings," -f Yellow
Write-Host "   then use the -isEntra yes (default) flag.  If it is" -f Yellow
Write-Host "   old style, use the -isEntra no flag" -f Yellow
Write-Host "ASB - /eCMSVersions on" $which":  Test Failed " -f Red
exit 1
