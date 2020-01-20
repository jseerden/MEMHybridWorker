param (
    [Parameter (Mandatory = $true)]
    $azAutomationUrl,

    [Parameter (Mandatory = $true)]
    $azAutomationKey
)

# Check which version of the solution has been downloaded
$azureAutomationVersion = (Get-ChildItem -Path 'C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\')[0].Name

# Register the machine as a Hybrid Worker in your Azure Automation account, using the hostname as Hybrid Worker Group name.
Import-Module "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\$azureAutomationVersion\HybridRegistration\HybridRegistration.psd1"
Remove-HybridRunbookWorker -Url $azAutomationUrl -Key $azAutomationKey
Remove-Module "HybridRegistration"

# Uninstall the Microsoft Monitoring Agent
Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/x `"{3CC28940-B587-4B46-9F18-9927D6F13202}`" /qn"