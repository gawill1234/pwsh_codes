First, goggletest_env.ps1 is a test install.  While it installs a
real app, it's just for experimentation.  Now, moving on ...

The true deploy will vary with the app being deployed.
As we go forward, these deploy issues will need to be resolved.
Bear in mind, these are very doable tasks.  They just need to be
recognized.

Deployment directory and app pool need to be selectable or supplied
by the script user.  There should be a default based on the app
and the location the script is running.  Either that, or the default
pools and directories must be common across environments/servers.

OOD, in terms of deployment, is pretty straight forward.

EBSProfile, EBSAdmin and EASAdmin have path selection bit built in
to the code.  It has to be found and reset based on the name of the pool
and directory actually being used.  If you don't, running the installed
pool looks for a directory name EBSProfile (for example).  So starting
in Zeta_GW2 still tries to look in EBSProfile.  Barring that, it gets
an error issued by the application.

EpicWebService, JobScheduler and EBSTimerJobs are "background"
applications that have special circumstances for their installs.

EpicWebService needs access to a local database and a local sharepoint
access point in order to function.  The database we have.  We do not
yet have a local sharepoint to use.

eCOR looks pretty much like OOD, so seemingly easy to deploy.

Force, ironically, also looks to be fairly simple in terms of deployment.

ASB has yet to be determined.  However, OOD, Force, eCOR and pretty much
everything else has one required modification to their deployment.  Each
must have their appsettings.json file updated to point at the ASB being
used (which may or may not be the "global" ASB for that system).

## Command line:
###   auto_deploy.ps1
```
       Will ask you questions to gather the info about what you want
       to install.
```
###   auto_deploy.ps1 -BuildMode BuildOnly
```
       Will only ask about the application itself and will build it.
       But it will not be deployed.  Just built.
       Coming soon, NoBuild.  Will only deploy using a previously
       existing build.
```

###   auto_deploy.ps1 -SaveFileName <some_name_ending_in_.ps1>
```
       Will ask the same questions and save the data to the named file.
```

###   auto_deploy.ps1 -ReadFileName <name_of_previously_saved_file.ps1>
```
       Will get all the necessary deploy info from the supplied file.
       No questions will be asked.
```

###   auto_deploy.ps1 -AllDirectory <name_of_a_directory>
```
       The directory should contain a series of .ps1 files, previously
       saved.  The tool will process each of the files and deploy all
       of those items as described in the files.  No questions will be
       asked.  Any files without a .ps1 suffix will be ignored.
```
