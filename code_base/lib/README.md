## appenvactions.ps1 -- function get_app_list
```
Gets the application list needed for the given targer server
and action.
```
## appenvactions.ps1 -- function get_env_list
```
Sets the environment list.
```
## appenvactions.ps1 -- function internal_match
```
Determines if a selected server and application can go together.
I.e., for external servers, return external applications.  Or
similar for internal.
```
## appenvactions.ps1 -- function external_match
```
Determines if a selected server and application can go together.
I.e., for internal servers, return internal applications.  Or
similar for external.
```
## appenvactions.ps1 -- function app_env_togetherness
```
```
## appenvactions.ps1 -- function getRemoteAddress
```
Get the actual "address" for a selected server.
```
## appenvactions.ps1 -- function SelectRemoteServer
```
Which server do you want the app installed to?
```
## appenvactions.ps1 -- function SelectApplication
```
Which application do you want to install?
```
## appenvactions.ps1 -- function VerifySelections
```
Verify that your selections are what you expected.
```
## gitactions.ps1 -- function git_clone_repo
```
Clone a repo if necessary.
```
## gitactions.ps1 -- function doweclone
```
Is it necessary to clone a repo based on repo location.
```
## gitactions.ps1 -- function git_checkout_config
```
Checkout the configuration branch we want.
```
## gitactions.ps1 -- function git_checkout_application
```
Checkout the application branch we want.
```
## gitactions.ps1 -- function git_current_branch
```
Return the current branch of a repo.
```
## gitactions.ps1 -- function git_correct_branch
```
Is the branch we are on the one we expect to be on?
```
## myFunctions.ps1 -- function runUpdateVersion
```
Run the updateVersion.ps1 script for an application if it
is there.
```
## myFunctions.ps1 -- function Test-ReparsePoint
```
Is a leaf/folder in a path a link or symlink.
```
## myFunctions.ps1 -- function make-link
```
Create a symbolic link from link to target.
```
## myFunctions.ps1 -- function checkfilesuffix
```
Does a file name have the suffix we need it to?
```
## myFunctions.ps1 -- function LinkOrDirectoryIsGood
```
Does leaf/link name exist within a directory.
```
## myFunctions.ps1 -- function checkandcopycomponents
```
Copy components to the location we need them.
```
## myFunctions.ps1 -- function InputDirectoryIsGood
```
Is a path element a directory and does it exist.
Not necessarily in that order.
```
## myFunctions.ps1 -- function InputFileIsGood
```
Is a path element a file and does it exist.
Not necessarily in that order.
```
## myFunctions.ps1 -- function buildthepath
```
Create a path if it does not exist.  Creates
all of the missing elements in the named path.
```
## myFunctions.ps1 -- function amiadministrator
```
Is this running in administrator mode?
```
## myFunctions.ps1 -- function returnAppEnvFile
```
Get the application data file if it has been requested.
For doing "read from here" and runAll ops.  Makes it 
so the questions do not have to be answered.
```
## myFunctions.ps1 -- function newPublishProfile
```
Create a new publish profile for putting the published
app somewhere new.
```
## myFunctions.ps1 -- function buildProfilePath
```
Locate the publish profile file
```
## myFunctions.ps1 -- function get_publish_location
```
Get the publish location if it is from a new file
for a new location.
```
## myFunctions.ps1 -- function clearBackups
```
Get rid of older backup files if the count exceeds 3.
```
## myFunctions.ps1 -- function getConfigFileLoc
```
Where are the config files located.
```
## myFunctions.ps1 -- function izitzipit
```
Is a zip file required.  Depends on the remote server
selected.
```
## myFunctions.ps1 -- function zip_not_deploy
```
Set the deploy flag to cause it to just create a
zip file instead of doing the deploy.
```
## myFunctions.ps1 -- function runAll
```
If the run everything option is set.  Check that
the directory exists and do all of the installs.
```
## myFunctions.ps1 -- function dump_file_data
```
Dump data so it can be seen.  For debugging.
```
## myFunctions.ps1 -- function save_file
```
Save the configuration/applications information to
the named file.  Used if you want to save that data
to be read and used later.  Rather than answering
questions.
```
## myFunctions.ps1 -- function continueortryagain
```
Should we continue.  Used if an issue was found that could
be ignored.
```
## myFunctions.ps1 -- function SelectAnswerYesNo
```
Get the answer to a yes/no question.
```
## myFunctions.ps1 -- function get_app_project_directory
```
Get the name of the project directory where the application
repo either exists or you want it placed.  For the app itself.
```
## myFunctions.ps1 -- function get_project_directory
```
Get the name of the project directory where the application
repo either exists or you want it placed.  For pool and 
remote directory names.
```
## myFunctions.ps1 -- function copy_app
```
Copy application files to the named remote pool/directory.
```
## myFunctions.ps1 -- function copy_configs
```
Copy config files to the named remote pool/directory.
```
## myFunctions.ps1 -- function backup_current_app
```
Create a backup of an app with a remote pool/directory.
```
## myFunctions.ps1 -- function publish_the_application
```
Run the build/publish for msbuild or dotnet
```
## poolactions.ps1 -- function get_application_pool
```
Get the name of the pool to use later.
```
## poolactions.ps1 -- function pool_status
```
Get the current pool status (start or stop)
```
## poolactions.ps1 -- function stop_pool
```
Stop a started pool.
```
## poolactions.ps1 -- function start_pool
```
Start a stopped pool.
```
