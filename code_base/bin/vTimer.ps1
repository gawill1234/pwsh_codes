#! pwsh
#
#  vTimer - visual timer
#
#  Built for the stupidest of reasons.  An attempt
#  to prevent the remote desktop from closing due
#  to lack of activity.  For some of these inactive
#  close functions, any output will cause them to
#  stay open.  So, print some data with returns to
#  "emulate" some stupid activity and keep the session
#  open.  I have no idea if it works yet.
#
#  Also, illustrates use of Get-Date, forced CR/NL, no
#  NL (new line).  And '1' is interpreted as True by a
#  while loop.  Use <ctrl>C to kill this.
#

$color_list = @("Blue", "Cyan", "Gray", "Green", "Magenta", "Red", "White", "Yellow", "DarkBlue", "DarkCyan", "DarkGray", "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow")

$cc = 0
$count = 0
$mything = 0
while (1) {
   $seconds = $count * 5
   if ($seconds % 60 -eq 0) {
      Write-Host "`r`n---"
      $elapsed = $seconds / 60
      Write-Host (Get-Date) "/ Elapsed: $elapsed minutes or $seconds seconds" -f $color_list[$cc]
      $mything = $seconds
   } else {
      $small = $seconds - $mything
      Write-Host "$seconds($small) " -NoNewline -f $color_list[$cc]
   }
   #
   #   Sleep not quite 5 seconds to attempt to account
   #   for processing "drift".  This is not perfect, but
   #   it is pretty close.
   #
   Start-Sleep -Seconds 4.985
   $count = $count + 1
   $cc = $cc + 1
   if ($cc -gt 14) {
      $cc = 0
   }
}
