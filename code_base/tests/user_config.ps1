
if ($isEntra -eq "yes") {
   $item = "X-OAS-UserGUID"
   $xoas = "8107a376-79dc-41af-b640-3219b9b5f564"
} elseif ($isEntra -eq "both") {
   $item = "X-OAS-UserGUID"
   $xoas = "8107a376-79dc-41af-b640-3219b9b5f564"
   $item2 = "X-OAS-UserEmail"
   $xoas2 = "gary.williams1@va.gov"
} else {
   $item = "X-OAS-UserEmail"
   $xoas = "gary.williams1@va.gov"
}
