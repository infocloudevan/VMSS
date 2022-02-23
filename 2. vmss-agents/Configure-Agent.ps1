param (
    $Pool,
    $agent,
    $InstallDirectory = "c:\script"
)

# Install Chocolatey
if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))}

choco install azure-cli -y

choco install vsts-cli -y

choco install azshell -y


$ErrorActionPreference = "Stop"

# Start transcription
Start-Transcript -Path (Join-Path -Path $env:TEMP -ChildPath "configure-agent.log") -Append

# Get an access token to query Azure Resource Manager
Write-Output "Acquiring access token"
$armTokenResponse = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -Headers @{Metadata = "true" } -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
$armToken = $armTokenResponse.access_token

# Get the subscription id
Write-Output "Finding subscription id"
$subscriptionsResponse = Invoke-WebRequest -Uri "https://management.azure.com/subscriptions?api-version=2019-06-01" -ContentType "application/json" -Headers @{ Authorization = "Bearer $armToken" } -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
$subscriptionId = $subscriptionsResponse.value[0].subscriptionId

$url = "https://dev.azure.com/moogenterpriseapps"
$pat = "fq3syph2kpkv3ml4uhcikyn23kqablbtq2axajlhfsswb3vkffua"
$installPackage = "https://vstsagentpackage.azureedge.net/agent/2.185.1/vsts-agent-win-x64-2.185.1.zip"
Write-Output "Url = $url"
Write-Output "pat = $pat"
Write-Output "Install Package = $installPackage"

# Download the agent package
Write-Output "Downloading agent"
$packageFile = Join-Path -Path $env:TEMP -ChildPath "vsts-agent-win-x64-2.184.2.zip"
Invoke-WebRequest -UseBasicParsing -Uri $installPackage -OutFile $packageFile

# Ensure the work directory is empty
Write-Output "Creating directory"
if (Test-Path -Path $InstallDirectory) {
    Remove-Item -Path $InstallDirectory -Recurse | Out-Null
}

# Expand the agent to the work directory
Write-Output "Extracting agent"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($packageFile, $InstallDirectory)

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Configure the agent
Write-Output "Configuring agent"
Set-Location $InstallDirectory
.\config.cmd --unattended --url $url --auth PAT --token $pat --pool "Default" --replace --runAsService


# Stop transcription
Write-Output "Done"
Stop-Transcript
