param (
    [Parameter (Mandatory = $true)]
    $workspaceId,

    [Parameter (Mandatory = $true)]
    $workspaceKey,

    [Parameter (Mandatory = $true)]
    $azAutomationUrl,

    [Parameter (Mandatory = $true)]
    $azAutomationKey,

    [Parameter (Mandatory = $false)]
    $maxRetries = 60
)

# Remove the install cmdlet that may containing the workspace and automation keys) from the log file
$intuneManagementExtensionLogPath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log"
Set-Content -Path $intuneManagementExtensionLogPath -Value (Get-Content -Path $intuneManagementExtensionLogPath | Select-String -Pattern "azAutomationKey" -notmatch)

# First, install the Microsoft Monitoring Agent and connect it to the Log Analytics Workspace
Start-Process -Wait -FilePath "$PSScriptRoot\setup.exe" -Argumentlist "/qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID=`"$workspaceId`" OPINSIGHTS_WORKSPACE_KEY=`"$workspaceKey`" AcceptEndUserLicenseAgreement=1"

# Wait for the AzureAutomation Solution to be downloaded by the Microsoft Monitoring Agent to the machine.
$i = 0
while ($true) {
    if (Test-Path -Path 'C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\') {
        Write-Output "AzureAutomation Module files are present on machine."
        break
    }
    if ($i -eq $maxRetries) {
        Write-Error "AzureAutomation Solution files not present. Has the Solution been added to the Log Analytics Workspace?" -ErrorAction Stop
    }

    Start-Sleep -Seconds 5
    $i++
}

# AzureAutomation folder is detected, but maybe some files are still being downloaded. Give it some more time before continuing..
Start-Sleep 10

# Check which version of the solution has been downloaded
$azureAutomationVersion = (Get-ChildItem -Path 'C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\')[0].Name

# Register the machine as a Hybrid Worker in your Azure Automation account, using the hostname as Hybrid Worker Group name.
Import-Module "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\$azureAutomationVersion\HybridRegistration\HybridRegistration.psd1"
Add-HybridRunbookWorker -GroupName $env:COMPUTERNAME -EndPoint $azAutomationUrl -Token $azAutomationKey