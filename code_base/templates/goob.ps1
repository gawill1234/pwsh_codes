function newPublishProfile {
   param ($nameIt, $newPubLoc, $pubFileName)

   Write-Host "Would write to this location: " $nameIt

   $publoc = '       <PublishUrl>' + $newPubLoc + '</PublishUrl>'

   $origpath = 'bin\app.publish'
   $header = '<?xml version="1.0" encoding="utf-8"?>
   <Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
     <PropertyGroup>
       <DeleteExistingFiles>True</DeleteExistingFiles>
       <ExcludeApp_Data>False</ExcludeApp_Data>
       <LaunchSiteAfterPublish>True</LaunchSiteAfterPublish>
       <LastUsedBuildConfiguration>Release</LastUsedBuildConfiguration>
       <PublishProvider>FileSystem</PublishProvider>
       <LastUsedPlatform>Any CPU</LastUsedPlatform>'
   $trailer = '       <WebPublishMethod>FileSystem</WebPublishMethod>
       <SiteUrlToLaunchAfterPublish />
     </PropertyGroup>
   </Project>'
   
   Write-Output $header > $pubFileName
   Write-Output $publoc >> $pubFileName
   Write-Output $trailer >> $pubFileName
   
}

function buildProfilePath {
   param ($oldProjPath, $newName)

   $newProfilePath = $oldProjPath + "\Properties\PublishProfiles\" + $newName

   return $newProfilePath
}

#
#  Get the applicaton pool the user wants to use to run things.
#
function get_publish_location {
   param ($PublishPath)

   $PublishName = Read-Host -Prompt "Input the application Publish Location.  Default is $PublishPath"

   if ([string]::IsNullOrWhiteSpace($PublishName)) {
      $PublishName = $PublishPath
      Write-Host "Using Default:  $PublishPath"
   } else {
      Write-Host "Using provided publication path:  $PublishName"
      if (-Not (Test-Path -Path $PublishName)) {
         Write-Host "Publication directory does not exist. It will be created at publish time ..." -ForegroundColor Yellow
      }
   }

   return $PublishName
}


$newName = "tempFileName.pubxml"
$PublishPath = "c:\USERS\VHABUTWILLIG\eCMS\-Scripts\Deploy\templates"
$ProjectPath = "d:\Gary\myproject\slndir"

$nameIt = buildProfilePath $ProjectPath $newName
$PublishName = get_publish_location $PublishPath

newPublishProfile $nameIt $PublishName "gibly"
