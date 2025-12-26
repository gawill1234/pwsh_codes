#
#   Build application/route URIs
#
#   This is VERY crude and should have a separate
#   library for creating/adding in the individual 
#   routes for any given application.  Mostly ASB.
#
#   This is also a mixed bag of items that should
#   be broken out into a couple of library files.
#   Something like appdata.ps1, routeselect.ps1, 
#   headerdata.ps1, etc.  Maybe not that detailed,
#   but anyone reading this should get the idea.
#

. ../lib/rt_table.ps1

function addArguments {
   param ($sofar = "", $newArgName, $newArgValue)

   if ($newArgValue -ne $null -and $newArgValue -ne "") {
      try {
         $newArgValue = [System.Web.HttpUtility]::UrlEncode($newArgValue)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $newArgValue = $newArgValue.Replace(' ', '%20')
         $newArgValue = $newArgValue.Replace('@', '%40')
      }

      if ($sofar -ne "") {
         $query_route = $sofar + "&" + $newArgName + "=" + $newArgValue
      } else {
         $query_route = $newArgName + "=" + $newArgValue
      }
      return $query_route
   } else {
      return ""
   }
   return ""
}

function findResultItem {
   param ($myjson, $lookingfor, $what)

   $itemcounter = 0
   $found = 0
   foreach ($item in $myjson.result) {
      $thing = $item.$what
      if ($thing -eq $lookingfor) {
         $found = 1
         break
      }
      $itemcounter = $itemcounter + 1
   }

   if ($found -eq 0) {
      return -1
   } else {
      return $itemcounter
   }
}
#
#   Choose the base of the uri based on
#   alpha, beta, or charlie.
#
function uri_base {
   param ($which, $port="")

   $URIBASE = ""

   $which = $which.ToLower()

   switch ($which) {
      "alpha" {
            $URIBASE = "https://vaww.dev.alpha.ecms.va.gov/"
            break
      }
      "beta" {
            $URIBASE = "https://vaww.dev.ecms.va.gov/"
            break
      }
      "charlie" {
            # $URIBASE = "https://vaww.dev.ifams.ecms.va.gov/"
            $URIBASE = "https://vaww.dev.uat.ecms.va.gov/"
            break
      }
      "test" {
            $URIBASE = "https://vaww.test.ecms.va.gov/"
            break
      }
      "preprod" {
            $URIBASE = "https://vaww.preprod.ecms.va.gov/"
            break
      }
      "here" {
            $URIBASE = "https://localhost:$port/"
            break
      }
      default {
            Write-Host "Specified target host $which not found.  Using local." -f Red
            $URIBASE = "https://localhost:$port/"
            break
      }
   }

   return $URIBASE

}

#
#   Mostly, for this, it will be ASB.  Maybe
#   always ASB.  But, it's here to try things.
#
function app_part {
   param ($Application)

   $apppart = ""

   $Application = $Application.ToLower()

   if ($Application -eq "asb") {
      $apppart = "esb/api"
   }

   return $apppart
}

#
#   Select the user based on what we are
#   trying to do something as.  Like as
#   swagger or something else.
#
function valid_user {
   param ($userfor)

   $un = ""
   $userfor = $userfor.ToLower()

   switch ($userfor) {
      "swagger" {
            $un = "swagger-user"
            break
      }
      "si" {
            $un = "access1"
            break
      }
      "ood" {
            $un = "OOD_access"
            break
      }
      "aams" {
            $un = "Aams_access"
            break
      }
      "cor" {
            $un = "COR_access"
            break
      }
      "ifams" {
            $un = "Momentum_access"
            break
      }
      "force" {
            $un = "force_access"
            break
      }
      default {
            $un = $userfor 
            break
      }
   }

   return $un
}

#
#   Select the password based on what we are
#   trying to do something as.  Like as
#   swagger or something else.
#
function valid_pw {
   param ($pwfor)

   $pw = ""
   $pwfor = $pwfor.ToLower()

   switch ($pwfor) {
      "swagger" {
            $pw = "DKS6f3BdZbZDWDxP"
            break
      }
      "si" {
            $pw = 'access1@va.eas.gov'
            break
      }
      "ood" {
            $pw = "sH2VogLuvx@MDyGCRZj6"
            break
      }
      "aams" {
            $pw = "gYmW8!GbQdwbT9@Ffk8r+wrfv"
            break
      }
      "cor" {
            $pw = "QW@kgsA1nPYWI9CJbd58"
            break
      }
      "ifams" {
            $pw = "4r7C2k@qLP9qMk6!NTkaHKPvL"
            break
      }
      "force" {
            $pw = 'HVID$z645dEH@Znm5@NA'
            break
      }
      default {
            $pw = "doesnotexist"
            break
      }
   }

   return $pw
}

#
#   Get the user/pw for a given item (swagger, etc)
#   as authfor.
#   Convert to a base 64 representation of the auth data.
#
function base64_auth {
   param ($authfor)

   $un = valid_user -userfor $authfor
   $pw = valid_pw -pwfor $authfor

   $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $un,$pw)))

   return $base64AuthInfo

}

#
#   Which ActiveDirectory route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_FORCERoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("formmodel")} {
            $base_route = "/Force/FormModel.v17-01"
            break
      }
      {$_.Contains("force/formmodel")} {
            $base_route = "/Force/FormModel.v17-01"
            break
      }
      {$_.Contains("force/activecontractingofficeid")} {
            $base_route = "/Force/ActiveContractingOfficeID"
            break
      }
      default {
            $base_route = "/Force/FormModel.v17-01"
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
   #   try {
   #      $query = [System.Web.HttpUtility]::UrlEncode($query)
   #      if ($verbose -ne $null -and $verbose -ne "") {
   #         Write-Host "UrlEncode passed:  Url properly encoded" -f Green
   #      }
   #   } catch {
   #      Write-Host "UrlEncode failed:  limited replace of characters" -f Red
   #      $query = $query.Replace(' ', '%20')
   #      $query = $query.Replace('@', '%40')
   #   }

      $query_route = $base_route + "?" + $query
      return $query_route
   }

   return $base_route
 
}

function do_AAMSRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("aams/artifacts")} {
            $base_route = "/Aams.v17-01/Artifacts"
            break
      }
      default {
            $base_route = "/Aams.v17-01/Artifacts"
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "?DocumentId=" + $query
      return $query_route
   }

   return $base_route
 
}

function do_AdminRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("jobs/history/summary")} {
            $base_route = "/Admin/Jobs/History/Summary.V17-01"
            break
      }
      default {
            $base_route = "/Admin/Jobs/History.v17-01"
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {

      $query_route = $base_route + "?" + $query
      return $query_route
   }
 
   return $base_route
}
#
#   Which ActiveDirectory route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_ADRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      "ad" {
            $base_route = "/ActiveDirectoryUser.v17-01"
            break
      }
      "msg" {
            $base_route = "/MSGraphUser.v17-01"
            break
      }
      {$_.Contains("activedirectoryuser")} {
            $base_route = "/ActiveDirectoryUser.v17-01"
            break
      }
      default {
            $base_route = "/ActiveDirectoryUser.v17-01"
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "?Term=" + $query
      return $query_route
   }
 
   return $base_route
}

function do_OODRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("oas/ood/nominationscount")} {
            $base_route = "/OAS/OOD/NominationsCount.v19-01"
            break
      }
      {$_.Contains("oas/ood/initializemassnomination")} {
            $base_route = "/OAS/OOD/InitializeMassNomination.v19-01"
            $base_route = $base_route + "?" + $query
            $query = ""
            break
      }
      {$_.Contains("oas/ood/groups")} {
            if ($query -eq "") {
               $base_route = "/OAS/OOD/Groups.v19-01"
            } else {
               $base_route = "/OAS/OOD/Groups.v19-01/" + $query
               $query = ""
            }
            break
      }
      {$_.Contains("oas/ood/documenttasks")} {
            $base_route = "/OAS/OOD/DocumentTasks.v19-01"
            break
      }
      {$_.Contains("oas/ood/user/documenttasks")} {
            if ($query -ne "") {
               $base_route = "/OAS/OOD/User/" + $query + "/DocumentTasks.v19-01"
               $query = ""
            }
            break
      }
      {$_.Contains("oas/ood/search/appointments")} {
            $base_route = "/OAS/OOD/Search/Appointments.v19-01/" + $query
            $query = ""
            break
      }
      {$_.Contains("oas/ood/configuration")} {
            if ($_.Contains("requireddocuments")) {
               $base_route = "/OAS/OOD/Configuration/RequiredDocuments.v19-01"
            } else {
               $base_route = "/OAS/OOD/Appointments.v19-01"
            }
            break
      }
      {$_.Contains("oas/ood/appointments")} {
            if ($_.Contains("history")) {
               $base_route = "/OAS/OOD/Appointments.v19-01/" + $query + "/History"
               $query = ""
            } else {
               $base_route = "/OAS/OOD/Appointments.v19-01"
            }
            break
      }
      {$_.Contains("oas/ood/nominations")} {
            if ($_.Contains("history")) {
               $base_route = "/OAS/OOD/Nominations/" + $query + "/History.v19-01"
               $query = ""
            } else {
               $base_route = "/OAS/OOD/Nominations.v19-01"
            }
            break
      }
      {$_.Contains("oas/ood/contract/nominations")} {
            if ($query -ne $null -and $query -ne "") {
               $base_route = "/OAS/OOD/Contract/" + $query + "/Nominations.v19-01"
               $query = ""
            } else {
               $base_route = "/OAS/OOD/Contract/Nominations.v19-01"
            }
            break
      }
      {$_.Contains("oas/ood/contracts/appointments")} {
            if ($query -ne $null -and $query -ne "") {
               $base_route = "/OAS/OOD/Contracts/" + $query + "/Appointments.v19-01"
               $query = ""
            } else {
               $base_route = "/OAS/OOD/Contracts/Appointments.v19-01"
            }
            break
      }
      default {
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query

      return $query_route
   }

   return $base_route
 
}

function do_ECORRoute {
   param ($route, $query = "", $query2 = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("oas/ecor/indices")} {
            $base_route = "/OAS/ECOR/Indices.v18-01"
            break
      }
      {$_.Contains("oas/ecor/issues")} {
            $base_route = "/OAS/ECOR/Issues.v19-01"
            break
      }
      {$_.Contains("oas/ecor/filesinitialize")} {
            $base_route = "/OAS/ECOR/FilesInitialize.v18-01" + $query
            $query = ""
            break
      }
      {$_.Contains("oas/ecor/user/files")} {
            $base_route = "/OAS/ECOR/User/" + $query + "/Files.v19-01"
            $query = ""
            break
      }
      {$_.Contains("oas/ecor/files/tasks")} {
            $base_route = "/OAS/ECOR/Files/" + $query + "/Tasks.v18-01"
            $query = ""
            break
      }
      {$_.Contains("oas/ecor/files")} {
            if ($_.Contains("users")) {
               $base_route = "/OAS/ECOR/Files/" + $query + "/Users.v18-01"
               $query = ""
               if ($query2 -ne "") {
                  $base_route = $base_route + "/" + $query2
               }
            } else {
               $base_route = "/OAS/ECOR/Files.v18-01"
            }
            break
      }
      {$_.Contains("oas/ecor/reports")} {
            $base_route = "/OAS/ECOR/Reports.v18-01"
            break
      }
      default {
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query

      return $query_route
   }

   return $base_route
 
}

function do_SearchRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("oas/search/users")} {
            $base_route = "/OAS/Search/Users.v18-01"
            break
      }
      default {
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         #
         #   Backwards for the moment because, until I
         #   sort out query params fully, I want to 
         #   limit what is encoded.
         #
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      }

      $query_route = $base_route + "?SearchValue=" + $query

      return $query_route
   }

   return $base_route
 
}

#
#   Which OAS route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_OASRoute {
   param ($route, $query = "", $query2 = "")

   #  Write-Host "do_OASRoute, route: " $route

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("oas/search/users")} {
            $base_route = do_SearchRoute -route $route -query $query
            $query = ""
            break
      }
      {$_.Contains("oas/users")} {
            if ($_.Contains("entra")) {
               $base_route = "/OAS/Users.v18-01/Entra?EntraObjectId=" + $query
               $query = ""
            } else {
               $base_route = "/OAS/Users.v18-01"
            }
            break
      }
      {$_.Contains("oas/ecert")} {
            if ($query -ne "") {
               $base_route = "/OAS/ECERT/User/" + $query + "/Accreditations.v19-01"
               $query = ""
            } else {
               $base_route = "/OAS/ECERT/Accreditations.v19-01"
            }
            break
      }
      {$_.Contains("oas/system/users")} {
            $base_route = "/OAS/System/Users.v18-01"
            break
      }
      {$_.Contains("oas/stations")} {
            if ($_.Contains("oas/stations/locations")) {
               $base_route = "/OAS/Stations/" + $query + "/Locations.v18-01"
               $query = ""
            } else {
               $base_route = "/OAS/Stations.v18-01"
            }
            break
      }
      {$_.Contains("oas/notificationtemplates")} {
            if ($query -ne "") {
               $base_route = "/OAS/NotificationTemplates.v18-01/" + $query
               $query = ""
            } else {
               $base_route = "/OAS/NotificationTemplates.v18-01"
            }
            break
      }
      {$_.Contains("oas/reports")} {
            if ($query -ne "") {
               $base_route = "/OAS/Reports.v18-01/" + $query
               $query = ""
            } else {
               $base_route = "/OAS/Reports.v18-01"
            }
            break
      }
      {$_.Contains("oas/organizations")} {
            if ($query -ne "") {
               $base_route = "/OAS/Organizations.v18-01?" + $query
               $query = ""
            } else {
               $base_route = "/OAS/Organizations.v18-01"
            }
            break
      }
      {$_.Contains("oas/locations/stations")} {
            $base_route = "/OAS/Locations/" + $query + "/Stations.v18-01"
            $query = ""
            break
      }
      {$_.Contains("oas/locations")} {
            $base_route = "/OAS/Locations.v18-01"
            break
      }
      {$_.Contains("oas/categories")} {
            $base_route = "/OAS/Categories.v18-01"
            break
      }
      {$_.Contains("oas/stationlocationpairs")} {
            $base_route = "/OAS/StationLocationPairs.v18-01"
            break
      }
      {$_.Contains("ecor")} {
           $base_route = do_ECORRoute -route $route -query $query -query2 $query2
           $query = ""
           break
      }
      {$_.Contains("ood")} {
           $base_route = do_OODRoute -route $route -query $query
           $query = ""
           break
      }
      "oas" {
            $base_route = "/OAS/Users.v18-01"
            break
      }
      default {
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "?Email=" + $query

      return $query_route
   }

   return $base_route
 
}

#
#  Contracts.v16-02/SP0200-02-D-8314/Conformed?OrderPIID=V797A63634-S
#
function do_ContractRoute {
   param ($route, $query = "", $query2 = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("contracts/activeawards")} {
            if ($_.Contains("awardedbetween")) {
               $base_route = "/Contracts/ActiveAwards/AwardedBetween.V20-01"
            } else {
               $base_route = "/Contracts/ActiveAwards.V20-01"
            }
            break
      }
      {$_.Contains("contracts/byproject")} {
            $base_route = "/Contracts/ByProject.V18-01"
            break
      }
      {$_.Contains("contracts/lineitems/idvlineitems")} {
            $base_route = "/Contracts/LineItems/IDVLineItems.V18-01"
            break
      }
      {$_.Contains("interface/contracts/lifecycleextended")} {
            $base_route = "/Interface/Contracts/LifecycleExtended.V25-01"
            break
      }
      {$_.Contains("contracts/conformed")} {
            $base_route = "/Contracts.v16-02/" + $query2 + "/Conformed"
            break
      }
      default {
            $route_part = $route
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      $query_route = $base_route + "?" + $query
      return $query_route
   }
 
   return $base_route
}
#
#   Which Vendor route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_ListRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   switch ($route) {
      {$_.Contains("assignmentcoordinatorsbyorg")} {
            $base_route = "/Lists/AssignmentCoordinatorsByOrg"
            break
      }
      {$_.Contains("contractofficeusersbyorg")} {
            $base_route = "/Lists/ContractOfficeUsersByOrg"
            break
      }
      {$_.Contains("awardtype")} {
            $base_route = "/Lists/AwardType.v16-01"
            break
      }
      {$_.Contains("classificationcode")} {
            $base_route = "/Lists/ClassificationCode.v16-01"
            if ($query -ne "") {
               $base_route = $base_route + "?" + $query
            }
            $query = ""
            break
      }
      {$_.Contains("fpdscontractingofficecode")} {
            $base_route = "/Lists/FpdsContractingOfficeCode.v16-01"
            break
      }
      {$_.Contains("fpdsextentcompeted")} {
            $base_route = "/Lists/FpdsExtentCompeted.v16-01"
            break
      }
      {$_.Contains("fpdsidctype")} {
            $base_route = "/Lists/FpdsIdcType.v16-01"
            break
      }
      {$_.Contains("fpdsidvtype")} {
            $base_route = "/Lists/FpdsIdvType.v16-01"
            break
      }
      {$_.Contains("fpdsreasonformodification")} {
            $base_route = "/Lists/FpdsReasonForModification.v16-01"
            break
      }
      {$_.Contains("naicscode")} {
            if ($_.Contains("planning")) {
               $base_route = "/Lists/NaicsCode/Planning.v16-01"
            } else {
               $base_route = "/Lists/NaicsCode.v16-01"
            }
            break
      }
      {$_.Contains("reviewassessment")} {
            if ($_.Contains("planning")) {
               $base_route = "/Lists/ReviewAssessment/Planning.v17-01"
            } else {
               $base_route = "/Lists/ReviewAssessment.v17-01"
            }
            break
      }
      default {
            $route_part = $route
            break
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query
      return $query_route
   }
 
   return $base_route
}

function do_OrgRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   if ($route -eq "/organizations") {
      $base_route = "/Organizations.v16-01"
   }
   if ($route -eq "/organizations/applicationFeatures") {
      if ($query -ne "") {
         $base_route = "/Organizations/" + $query + "/ApplicationFeatures.v17-01"
         $query = ""
      } else {
         $base_route = $route
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query
      return $query_route
   }
 
   return $base_route
}

#
#   Which Vendor route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_RequirementsRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   if ($route -eq "/requirements" -or $route -eq "requirements") {
      $base_route = "/Requirements.v17-01"
   }
   if ($route.Contains("requirements/datahistory")) {
      $base_route = "/Requirements/" + $query + "/DataHistory"
      $query = ""
   }
   if ($route.Contains("requirements/submissionstatuses")) {
      switch ($route) {
         {$_.Contains("requirements/submissionstatuses/assignment")} {
            $base_route = "/Requirements/SubmissionStatuses/AssignmentCoordinatorChanges.v17-01" + "?" + $query
            $query = ""
         }
         {$_.Contains("requirements/submissionstatuses/acquisitionpoc")} {
            $base_route = "/Requirements/SubmissionStatuses/AcquisitionPOCChanges.v17-01" + "?" + $query
            $query = ""
         }
         {$_.Contains("requirements/submissionstatuses/programofficeuser")} {
            $base_route = "/Requirements/SubmissionStatuses/ProgramOfficeUserChanges.v17-01" + "?" + $query
            $query = ""
         }
         {$_.Contains("requirements/submissionstatuses/mostrecent")} {
            $base_route = "/Requirements/" + $query + "/SubmissionStatuses/MostRecent.v16-01"
            $query = ""
         }
         default {
            $base_route = "/Requirements/" + $query + "/SubmissionStatuses.v16-01"
            $query = ""
         }
      }
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query
      return $query_route
   }
 
   return $base_route
}

function do_VersionRoute {
   param ($route)

   $base_route = $route
   $route = $route.ToLower()

   if ($route -eq "ecmsversion") {
      $base_route = "/eCMSVersion.v17-01"
   }
 
   return $base_route
}

function do_ErrorRoute {
   param ($route)

   $base_route = $route
   $route = $route.ToLower()

   if ($route -eq "errorcodelist") {
      $base_route = "/ErrorCodeList.v19-01"
   }
 
   return $base_route
}

function do_DistributionRoute {
   param ($route, $query)

   $base_route = $route
   $route = $route.ToLower()

   if ($route -eq "distributionlists") {
      $base_route = "/Core/DistributionLists/BySystem.V17-01"
   }

   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "/" + $query
      return $query_route
   }
 
   return $base_route
}


#
#   Which Vendor route do I want?
#   This is just trial of something that may not
#   be overly useful.  We'll see.
#
function do_VendorRoute {
   param ($route, $query = "")

   $route = $route.ToLower()

   if ($route -eq "vendorinfo") {
      $base_route = "/Vendors/VendorInfo.v21-01"
   }
   if ($route -eq "/vendors/vendorinfo") {
      $base_route = "/Vendors/VendorInfo.v21-01"
   }
   if ($route.Contains("vendors/vendorstatus")) {
      $base_route = "/Vendors/VendorStatus"
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      $query_route = $base_route + "?" + $query
      return $query_route
   }
 
   return $base_route
}

function do_UserRole {
   param ($route, $query = "")

   $route = $route.ToLower()

   if ($route -eq "userrole") {
      $base_route = "/UserRole.v16-01"
   }

   #
   #   You only UrlEncode the ATTRIBUTE section of a
   #   URI/URL.  So, the part after the question mark '?'.
   #   If you encode previous to that, you'll never find
   #   the web page you are looking for.
   #   There are exceptions to that, but not for our purposes.
   #
   if ($query -ne $null -and $query -ne "") {
      try {
         $query = [System.Web.HttpUtility]::UrlEncode($query)
         if ($verbose -ne $null -and $verbose -ne "") {
            Write-Host "UrlEncode passed:  Url properly encoded" -f Green
         }
      } catch {
         Write-Host "UrlEncode failed:  limited replace of characters" -f Red
         $query = $query.Replace(' ', '%20')
         $query = $query.Replace('@', '%40')
      }

      $query_route = $base_route + "?VendorName=" + $query
      return $query_route
   }
 
   return $base_route
}

#
#   Not used.  Held on to for future reference
#   if needed.  Will go away soon.
#
function get_full_route_old {
   param ($route, $query)

   $route = $route.ToLower()

   # Write-Host "get_full_route():  $route" -f DarkBlue

   if ($route -eq "vendorinfo") {
      $route_part = do_VendorRoute -route $route -query $query
      return $route_part
   }
   if ($route -eq "requirements") {
      $route_part = do_RequirementsRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("organization")) {
      $route_part = do_OrgRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("vendor")) {
      $route_part = do_VendorRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("vendorinfo")) {
      $route_part = do_VendorRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("assignmentcoordinator")) {
      $route_part = do_ListRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("oas")) {
      $route_part = do_OASRoute -route $route -query $query
      return $route_part
   }
   if ($route -eq "ad") {
      $route_part = do_ADRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("activedirectoryuser")) {
      $route_part = do_ADRoute -route $route -query $query
      return $route_part
   }
   if ($route.Contains("force")) {
      $route_part = do_FORCERoute -route $route -query $query
      return $route_part
   }

   return $route_part
}

#function route_by_id {
#   param ($routeId = 99999, $query = "", $query2 = "")
#
#   return ""
#}

function get_full_route {
   param ($route, $routeId = 99999, $query = "", $query2 = "")

   if ($routeId -ne 99999) {
      $route_part = route_by_id -routeId $routeId -query $query -query2 $query2
   } else {
      $route = $route.ToLower()

      # Write-Host "switched/get_full_route():  $route" -f DarkBlue

      switch ($route) {
         {$_.Contains("vendor")} {
            $route_part = do_VendorRoute -route $route -query $query
            break
         }
         {$_.Contains("requirements")} {
            $route_part = do_RequirementsRoute -route $route -query $query
            break
         }
         {$_.Contains("oas")} {
            $route_part = do_OASRoute -route $route -query $query -query2 $query2
            break
         }
         {$_.Contains("organization")} {
            $route_part = do_OrgRoute -route $route -query $query
            break
         }
         {$_.Contains("admin")} {
            $route_part = do_AdminRoute -route $route -query $query
            break
         }
         {$_.Contains("userrole")} {
            $route_part = do_UserRole -route $route -query $query
            break
         }
         {$_.Contains("aams")} {
            $route_part = do_AAMSRoute -route $route -query $query
            break
         }
         {$_.Contains("ecmsversion")} {
            $route_part = do_VersionRoute -route $route
            break
         }
         {$_.Contains("errorcodelist")} {
            $route_part = do_ErrorRoute -route $route
            break
         }
         {$_.Contains("distributionlist")} {
            $route_part = do_DistributionRoute -route $route -query $query
            break
         }
         {$_.Contains("lists")} {
            $route_part = do_ListRoute -route $route -query $query
            break
         }
         {$_.Contains("contracts")} {
            $route_part = do_ContractRoute -route $route -query $query -query2 $query2
            break
         }
         "ad" {
            $route_part = do_ADRoute -route $route -query $query
            break
         }
         "msg" {
            $route_part = do_ADRoute -route $route -query $query
            break
         }
         {$_.Contains("activedirectoryuser")} {
            $route_part = do_ADRoute -route $route -query $query
            break
         }
         {$_.Contains("force")} {
            $route_part = do_FORCERoute -route $route -query $query
            break
         }
         default {
            $route_part = $route
            break
         }
      }
   }

   return $route_part
}

function Add_route {
   param ($uri, $route, $routeId = 99999, $query = "", $query2 = "")

   if ($routeId -ne 99999) {
      $backroute = get_full_route -routeId $routeId -query $query -query2 $query2
   } else {
      $backroute = get_full_route -route $route -query $query -query2 $query2
   }

   $fullroute = $uri + $backroute

   return $fullroute
}


#
#   Crude attempt at building a full uri
#   from pieces parts.
#
function full_base_uri {
   param ($server, $app, $port="")

   $fbu = ""

   $ptA = uri_base -which $server -port $port
   if ($ptA -ne "") {
      $ptB = app_part -Application $app
      if ($ptB -ne "") {
         $fbu = $ptA + $ptB
      }
   }

   return $fbu

}

#
#   Add an item to the header dictionary.
#   Create the dictionary object if it is null/not specified
#
function build_headers {
   param ($headers, $key, $value)

   if ($headers -eq $null -or $headers -eq "") {
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
   }

   $headers.Add($key,$value)

   return $headers
}

#
#   Create an authorization header
#
function auth_header {
   param ($runas)

   $auth = base64_auth -authfor $runas
   $squigly = "Basic $auth"

   # $headers = @{Authorization = $squigly}
   $headers = build_headers -key Authorization -value $squigly

   return $headers
}

#
#   Run the uri
#   Does everything in one line.  But the
#   headers can be changed.
#
#   Need a variant where we can alter the body.
#
function run_uri_b {
   param ($uri, $headers)

   try {
      $Response = Invoke-WebRequest -Headers $headers -Uri "$uri" -UseBasicParsing 2>&1
   } catch {
      Write-Host "WebRequest Failed" -f Red
      $Response = $_
   }

   return $Response

}

function run_uri_put {
   param ($uri, $headers, $body)

   try {
      $Response = Invoke-WebRequest -Headers $headers -Method PUT -Body "$body" -Uri "$uri" -ContentType "application/json" -UseBasicParsing 2>&1
   } catch {
      Write-Host "WebRequest Failed" -f Red
      $Response = $_
   }

   return $Response

}

function run_uri_post {
   param ($uri, $headers, $body)

   try {
      $Response = Invoke-WebRequest -Headers $headers -Method POST -Body "$body" -Uri "$uri" -ContentType "application/json" -UseBasicParsing 2>&1
   } catch {
      Write-Host "WebRequest Failed" -f Red
      $Response = $_
   }

   return $Response

}

function run_uri_delete {
   param ($uri, $headers, $body = "")

   try {
      if ($body -ne "") {
         $Response = Invoke-WebRequest -Headers $headers -Method DELETE -Body $body -Uri "$uri" -ContentType "application/json" -UseBasicParsing 2>&1
      } else {
         $Response = Invoke-WebRequest -Headers $headers -Method DELETE -Uri "$uri" -UseBasicParsing 2>&1
      }
   } catch {
      Write-Host "WebRequest Failed" -f Red
      $Response = $_
   }

   return $Response

}


#
#   Run the uri
#   Does everything in one line.  Kind of 
#   fixed item.
#
function run_uri {
   param ($uri, $runas)

   $auth = base64_auth -authfor $runas

   try {
      $Response = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $auth)} -Uri "$uri" -UseBasicParsing 2>&1
   } catch {
      Write-Host "WebRequest Failed" -f Red
      $Response = $($_.Exception.Message)
   }

   return $Response

}

