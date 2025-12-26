#! pwsh
#
param ($which = "alpha",
       $runas = "swagger",
       $isEntra = "yes",
       $port = "",
       $dump = "")

#
#   For the moment, this MUST be run from ths "test" directory.
#   I makes no effort to "find" itself in the file system.
#
#   It is here as a crude example of running a route/api test
#   without using swagger or selenium.  Since ASB is, forg
#   all intents and purposes, a service, it is treated as such.
#   That means the URI is sent to ASB in a similar way to what
#   swagger would do.  The pass/fail processing here is very
#   simple and would need to have json result processing added.
#   With that, it would be possible pick out individual json
#   sections (status, result count, text) to further ensure that
#   the test did actually pass.
#
#   https://vaww.dev.alpha.ecms.va.gov/esb/api/Requirements.v17-01/1
#

. ../lib/appstatus.ps1
. ./user_config.ps1

if ($which -eq "test") {
   $ans = 28140
} else {
   $ans = 26329
}

#
#   Build the uri for the server and add the asb part.
#
$myuri = full_base_uri -server $which -app "asb" -port $port

#
#   Add on the actual route/api part.  The specific
#   bit that says what to do.  This is a very simple
#   Requirements query.
#
$fulluri = Add_route -uri $myuri -routeId 123

#
#   Run the test with the uri.  The run_uri function
#   will add in the appropriate user auth data for a swagger
#   user.
#
Write-Host "Running as: " $runas -f Yellow
$headers = auth_header -runas "$runas"
#$headers = build_headers -headers $headers -key "$item" -value "$xoas"
# TODO: replace this X-Token with a test user's value
$headers = build_headers -headers $headers -key "X-Token" -value "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy91cG4iOiI1NGEyMDI0My02ZjNhLTRhNmItYTFhYi1hNDE0ODYzNDU2ZTMiLCJleHAiOjE3NDk4Mzk5ODgsImlzcyI6Imh0dHA6Ly9jZW50ZXZhLmNvbSIsImF1ZCI6IjU0YTIwMjQzLTZmM2EtNGE2Yi1hMWFiLWE0MTQ4NjM0NTZlMyJ9.rlYdNaOx6DivGSi5qWkHE5ijd2RRj0uI4Bci11ps9Bk"

#$headers = build_headers -headers $headers -key "X-Token" -value "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkdhcnkgV2lsbGlhbXMiLCJpYXQiOjE1MTYyMzkwMjJ9.GluNr1-ek8-3CBm19Y7cOBRzyVTqd20WYTPsHeFV7Xk"

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
      Write-Host ($Response | ConvertFrom-Json | ConvertTo-Json -Depth 9)
   } catch {
      Write-Host $Response
   }
}

Write-Host "URI:  $fulluri" -f magenta
Write-Host "Basic get" -f magenta
if ($Response.StatusCode -eq 200) {
   $mine = ($Response.Content | ConvertFrom-Json)
   if ($mine.result.Id -eq $ans) {
      Write-Host "ASB - /Users/Current" $which":  Test Passed " -f Green
      exit 0
   }
}

Write-Host $Response
Write-Host "ASB - /Users/Current" $which":  Test Failed " -f Red

exit 1


