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
#   A quick search test to check that case does not affect the
#   search result.  There are 2 lists.  The search result for 
#   each should be the same.
#

. ../lib/appstatus.ps1

. ./user_config.ps1

$tname = "search3.ps1"
$Global:fail = 0

$strlist = @("J", "Ja", "Jam", "James", "T", "Ta", "Tam", "Tamm", "Tammy")
$strlist2 = @("j", "ja", "jam", "james", "t", "ta", "tam", "tamm", "tammy")

function runtest {
   param ($thislist)
 
   $mycountlst = New-Object System.Collections.ArrayList

   $possible = 0
   $correct = 0

   foreach ($thing in $thislist) {
      #$fulluri = Add_route -uri $myuri -route "OAS/Search/Users" -query $thing
      $argSet = addArguments -newArgName "SearchValue" -newArgValue $thing
      $fulluri = Add_route -uri $myuri -routeId 37 -query $argSet
      $Response = run_uri_b -uri $fulluri -headers $headers
      Write-Host "URI:  $fulluri" -f magenta
      if ($Response.StatusCode -eq 200) {

         $mine = ($Response.Content | ConvertFrom-Json)
         Write-Host "ASB - OAS/Search/Users search term: " $thing -f Green
         Write-Host "ASB - OAS/Search/Users count      : " $mine.Result.Count -f Green
         if ($mine.Result.Count -ge 1) {
            $locid = $mine.Result[0].Id
            $possible = $possible + 1
            if ($locid -ne "" -and $locid -ne $null) {
               $correct = $correct + 1
               Write-Host "ASB - OAS/Search/Users ID         : " $locid -f Green
               [void]$mycountlst.Add($mine.Result.Count)
            }
         }
         Write-Host "======================" -f Yellow
      } else {
         Write-Host $tname": ASB - OAS/Search/Users - access fail" -f Red
         $Global:fail = $Global:fail + 1
      }
   }

   return $mycountlst
}

Write-Host $tname": Search case sensitivity checks" -f Green
#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
if ($isEntra -eq "both") {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
   $headers = build_headers -headers $headers -key "$item2" -value "$xoas2"
} else {
   $headers = build_headers -headers $headers -key "$item" -value "$xoas"
}

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   search query
#
$lst1 = runtest -thislist $strlist
$lst2 = runtest -thislist $strlist2

if ($Global:fail -ne 0) {
   Write-Host $tname": ASB - OAS/Search/Users had at least one access fail" -f Red
   $failcnt = 1
} else {
   $failcnt = 0
}

$cnt = 0
$passcnt = 0
foreach ($thing in $lst1) {
   if ($thing -ne $lst2[$cnt]) {
      $failcnt = $failcnt + 1
   } else {
      $passcnt = $passcnt + 1
   }
   $cnt = $cnt + 1
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
   Write-Host $lst1
   Write-Host $lst2
   Write-Host "Count = $cnt, Pass = $passcnt, Fail = $failcnt"
}

if ($passcnt -eq $cnt) {
   if ($failcnt -eq 0) {
      Write-Host $tname": ASB - OAS/Search/Users count verification passed" -f Green
      Write-Host $tname": ASB - OAS/Search/Users on" $which":  Test Passed " -f Green
      exit 0
   }
}

if ($possible -gt 0 -and $correct -gt 0) {
   Write-Host $tname": ASB - OAS/Search/Users possible matches : $possible" -f Red
   Write-Host $tname": ASB - OAS/Search/Users actual matches   : $correct" -f Red
}
Write-Host $tname": ASB - OAS/Search/Users on" $which":  Test Failed " -f Red
exit 1


