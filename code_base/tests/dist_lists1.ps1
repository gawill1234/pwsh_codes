#! pwsh
#
param ($which = "alpha",
       $runas = "swagger",
       $query = "Epic",
       $port = "",
       $dump = "")

$valid_list = @("aams", "all", "care", "dbmigrator", "eas.ipc", "epic", "epicwebservice", "epicservice", "epicexternalwebservice", "esb", "evp", "force", "ifams", "ifcap1g", "vipservice", "webauthproxy_elasticsearch")

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

function in {
   param ($thing, $thinglist)

   $thinglist | ForEach {
      if ($thing -eq $_) {
         return 1
      }
   }

   return 0
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

$query = $query.ToLower()

$go = in -thing $query -thinglist $valid_list

if ($go -eq 0) {
   Write-Host "$query is not a valid search item" -f Red
   Write-Host "Valid Items:  $valid_list" -f Yellow
   Write-Host "ASB - /Core/DistributionLists/BySystem on" $which":  Query Failed " -f Red
   exit 1
}

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
#   Core/DistributionLists/BySystem.V17-01
#
#$fulluri = Add_route -uri $myuri -route "DistributionLists" -query $query
$fulluri = Add_route -uri $myuri -routeId 86 -query $query

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
try {
   $Response = run_uri_b -uri $fulluri -headers $headers
} catch {
   Write-Host "URI:  $fulluri" -f magenta
   Write-Host $Response
   Write-Host "ASB - /Core/DistributionLists/BySystem on" $which":  Query Failed " -f Red
   exit 1
}


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
   $mine = ($Response.Content | ConvertFrom-Json)
   Write-Host "ASB - /Core/DistributionLists/BySystem on" $which",  Count: " $mine.Count -f Green
   if ($mine.Count -eq 1) {
      Write-Host "ASB - /Core/DistributionLists/BySystem on" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host "ASB - /Core/DistributionLists/BySystem on" $which":  Test Failed " -f Red
exit 1
