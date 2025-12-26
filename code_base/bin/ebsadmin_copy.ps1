#! pwsh
#
param ([string]$MyRepo = "",
       [string]$ComponentRepo = "",
       [string]$Base = "")

#
#  Create a symlink
#
function make-copy {
   param ($target, $link)

   if (Test-Path -Path $link) {
      $link = Split-Path $link -Parent
   }


   $farkle = Copy-Item $target -Destination $link -Recurse 2>&1

   return $?
}

if ($Base -eq "") {
   $Base = "d:\Application_Development\Shared\AutoDeploy"
}
if ($MyRepo -eq "") {
   $MyRepo = $Base + "\Apps\-EBSAdmin"
}
if ($ComponentRepo -eq "") {
   $ComponentRepo = $Base
}

$myLink = $MyRepo + "\ClientApp"

$myTarget = $ComponentRepo + "\AppComponents\-EBSAdmin\ClientApp"

Write-Host "Copying node_modules from $myTarget to $myLink" -f Green
Start-Sleep -seconds 2

$goob = make-copy -target $myTarget\node_modules -link $myLink\node_modules
if (-not $goob) {
   Write-Host "$myLink\node_modules already exists" -f Red
} else {
   Write-Host "$myLink\node_modules copied" -f Green
}
