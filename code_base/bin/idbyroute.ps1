#! pwsh
#
param ($routestring = "")

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

$ScriptPath = findOurRoot

. $ScriptPath/lib/appstatus.ps1
. $ScriptPath/lib/rt_table.ps1

if ($routestring -ne "") {
   findIdByRouteString -routeString $routestring
}
