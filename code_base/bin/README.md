This directory contains a number of commands to install or assist
in the installation of applications.

## auto_deploy.ps1
Will deploy applications to the select locatation.  It will ask
questions to determine which app, which branch, and which location
to send it to.
Options:  -BuildMode <mode> mode would be "BuildOnly"
Only do the build.  Otherwise it does the full deploy.
          -Build <yes|no> default is yes.  If no, build a package
without rebuilding.

## ecms_Versions.ps1
Get the current versions of apps on the selected host
Options:  -which <target>  (one of alpha, beta, charlie)

## error_codes.ps1
List the error code meanings on the selected host
Options:  -which <target>  (one of alpha, beta, charlie)

## dist_lists.ps1
Get the distribution lists for a selected app on a selected host
Options:  -which <target>  (one of alpha, beta, charlie)
          -query <app_name> (one of the apps, default is ASB)

## xxxx_link.bat
In the windows command prompt, create a symbolic link within the
product to all of the bower/node/ember installs.

## xxx_link.ps1
In the powershell command prompt, create a symbolic link within the
product to all of the bower/node/ember installs.

## xxxx_copy.bat
In the windows command prompt, copy the ember/bower/node installs
into the product directory which needs them (xxxx)

## xxx_copy.ps1
In the powershell command prompt, copy the ember/bower/node installs
into the product directory which needs them (xxxx)

## colors.ps1
Show colors available in powershell for output enhancement.

## asb_up.ps1
Powershell, is asb up or down

## asb_up.sh
bash, is asb up or down

## AmIAdmin.ps1
Does your current powershell have admin privileges.

## vTimer.ps1
Powershell, ticks off 5 second intervals.  Written as an experiment
to see if the activity would keep window open (no lock, it does not).
