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

try {
   . ../lib/rt_table.ps1
} catch {
}

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
   param ($Application, $which = "")

   $apppart = ""

   $Application = $Application.ToLower()

   if ($which -eq "here") {
      $apppart = "api"
   } else {
      if ($Application -eq "asb") {
         $apppart = "esb/api"
      }
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

function get_full_route {
   param ($route, $routeId = 99999, $query = "", $query2 = "", $query3 = "", $params = "")


   if ($routeId -ne 99999) {
      $route_part = route_by_id -routeId $routeId -query $query -query2 $query2 -query3 $query3 -params $params
   } else {
      $route = $route.ToLower()

      $rid = getIdByRouteString -routeString $route
      $route_part = route_by_id -routeId $rid -query $query -query2 $query2 -query3 $query3 -params $params

      # Write-Host "switched/get_full_route():  $route" -f DarkBlue

   }

   return $route_part
}

function Add_route {
   param ($uri, $route, $routeId = 99999, $query = "", $query2 = "", $query3 = "", $params = "")

   if ($routeId -ne 99999) {
      $backroute = get_full_route -routeId $routeId -query $query -query2 $query2 -query3 $query3 -params $params
   } else {
      $backroute = get_full_route -route $route -query $query -query2 $query2 -query3 $query3 -params $params
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
      $ptB = app_part -Application $app -which $server
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

function dump_headers {
   param ($headers)

   foreach ($key in $headers.Keys) {
      Write-Output "$key : $($headers[$key])"
   }
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

