#! pwsh
#
#   Write in each of the available colors for Write-Host
#

$color_list = @("Black", "Blue", "Cyan", "Gray", "Green", "Magenta", "Red", "White", "Yellow", "DarkBlue", "DarkCyan", "DarkGray", "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow")

foreach ($color in $color_list) {
   Write-Host "##################" -f $color
   Write-Host "Color:  $color"
   Write-Host "hello there $color" -f $color
   Write-Host "##################" -f $color
}

Write-Host "FYI, the point of this script is to show the colors"
Write-Host "available for the Write-Host action in powershell."
