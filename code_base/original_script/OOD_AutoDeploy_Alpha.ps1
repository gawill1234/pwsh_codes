Write-Host "`n`n===================================================================================================`n`n`n OOD Auto Deploy Alpha `n`n`n==================================================================================================="

# Variables
$ScriptPath = "D:\AutoDeploy\Scripts"

$ProjectPath = "D:\AutoDeploy\Apps\-OOD\src\OOD"
$PublishPath = "D:\AutoDeploy\Apps\-OOD\src\OOD\OOD\bin\Release\net8.0\publish"

$RemoteServer = "vac20appaes800.va.gov"  # Change to your VM name
$RemotePath = "\\$RemoteServer\d$\_devZeta\wwwroot\JA\OOD"

$ConfigPath = "D:\AutoDeploy\Apps\-eCMSConfigFiles" 
$ConfigAppPath = "D:\AutoDeploy\Apps\-eCMSConfigFiles\OOD\DevAlpha"

$AppPoolName = "Zeta_JA_OOD"

# Navigate to the project directory
Set-Location -Path $ConfigPath

# Checkout the proper config branch
Write-Host "`n`n==================================================================================================="
Write-Host "Fetching Origin of eCMSConfigFiles and checking out branch"
Write-Host "==================================================================================================="
git fetch origin
$branch = git branch -r --format='%(refname:short)' | ForEach-Object { $_ -replace '^origin/', '' } | Sort-Object | Out-GridView -Title "Select a Git Branch" -OutputMode Single
if ($branch) { 
	Write-Host "Checking out the $branch branch..." 
	git reset
	git checkout $branch 
	git pull
}

# Navigate to the project directory
Set-Location -Path $ProjectPath

# Checkout the proper app branch
Write-Host "`n`n==================================================================================================="
Write-Host "Fetching Origin of eCMSConfigFiles and checking out branch"
Write-Host "==================================================================================================="

git fetch origin
$branch = git branch -r --format='%(refname:short)' | ForEach-Object { $_ -replace '^origin/', '' } | Sort-Object | Out-GridView -Title "Select a Git Branch" -OutputMode Single
if ($branch) { 
	Write-Host "Checking out the $branch branch..." 
	git reset
	git checkout $branch 
	git pull
}

# Publish the .NET Project
Write-Host "`n`n==================================================================================================="
Write-Host "Publishing the .NET project..."
Write-Host "==================================================================================================="

if (!(Test-Path -Path $PublishPath)) {
    Write-Host "Folder does not exist. Creating it now..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $PublishPath | Out-Null
    Write-Host "Folder created: $PublishPath" -ForegroundColor Green
} else {
    Write-Host "Folder already exists: $PublishPath" -ForegroundColor Yellow
}

dotnet publish $ProjectPath -c Release -o $PublishPath

# Backup the existing remote folder
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupPath = "$RemotePath`_Backup_$Timestamp"

Write-Host "`n`n==================================================================================================="
Write-Host "Backing up current deployment to: $BackupPath..."
Write-Host "==================================================================================================="
Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
    param ($Source, $Backup)
    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Backup -Recurse -Force
        Write-Host "Backup completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Warning: Source path does not exist, skipping backup." -ForegroundColor Red
    }
} -ArgumentList $RemotePath, $BackupPath

# Stop the IIS App Pool
Write-Host "`n`n==================================================================================================="
Write-Host "Stopping App Pool: $AppPoolName on $RemoteServer..."
Write-Host "==================================================================================================="
Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
    param ($AppPool)
    Import-Module WebAdministration
    Stop-WebAppPool -Name $AppPool
} -ArgumentList $AppPoolName

# Copy files to the remote server, ensuring all files are overwritten
Write-Host "`n`n==================================================================================================="
Write-Host "Copying files to the remote server..."
Write-Host "==================================================================================================="
# Ensure all files are overwritten and delete files that no longer exist
Robocopy $PublishPath $RemotePath /MIR /R:5 /W:2 /NP /XD logs /XF appsettings.json web.config log4net.config

# Copy files to the remote server, ensuring all files are overwritten
Write-Host "`n`n==================================================================================================="
Write-Host "Copying configs to the remote server..."
Write-Host "==================================================================================================="
# Ensure all files are overwritten and delete files that no longer exist
Robocopy $ConfigAppPath $RemotePath /R:5 /W:2 /NP /XD logs /XF _placeholder.txt

# Start the IIS App Pool
Write-Host "`n`n==================================================================================================="
Write-Host "Starting App Pool: $AppPoolName on $RemoteServer..."
Write-Host "==================================================================================================="
Invoke-Command -ComputerName $RemoteServer -ScriptBlock {
    param ($AppPool)
    Import-Module WebAdministration
    Start-WebAppPool -Name $AppPool
} -ArgumentList $AppPoolName

# Navigate to the project directory
Set-Location -Path $ScriptPath
Write-Host "`n`nDeployment completed successfully!`n" -ForegroundColor Green