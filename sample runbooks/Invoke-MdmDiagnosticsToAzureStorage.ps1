$date = (Get-Date -Format o).Split("T")[0]

Write-Output "Checking if the Azure.Storage PowerShell Module is present ..."
if( -not (Get-InstalledModule Azure.Storage -ErrorAction SilentlyContinue)) {
    Write-Output "Installing the Azure.Storage PowerShell Module ..."
    Install-Module Azure.Storage -Confirm:$false -Force
}

Write-Output "Retrieving the Storage Account Name and Key from Azure Automation Variable Shared resources ..."
$storageAccountName = Get-AutomationVariable -Name "StorageAccountName"
$storageAccountKey = Get-AutomationVariable -Name "StorageAccountKey"

Write-Output "Collecting Mobile Device Management Diagnostics ..."
# Supported area's "Autopilot;DeviceEnrollment;DeviceProvisioning;TPM"
MdmDiagnosticsTool.exe -area "Autopilot" -zip "$($env:TEMP)\$($date)_$($env:COMPUTERNAME)_MdmDiagnostics.zip"

$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

Write-Output "Creating the a Container to store the Mobile Device Management Diagnostics in the Azure Automation account, if it does not yet exist ..."
$containerName = "mdmdiagnostics"

if (-not (Get-AzureStorageContainer -Name $containerName -Context $ctx -ErrorAction SilentlyContinue)) {
    New-AzureStorageContainer -Name $containerName -Context $ctx -Permission Blob
}

Write-Output "Uploading the MdmDiagnostics zip file to the Azure Storage Account ..."
$file = "$($env:TEMP)\$($date)_$($env:COMPUTERNAME)_MdmDiagnostics.zip"
Set-AzureStorageBlobContent -File $file -Container $containerName -Blob "$($date)_$($env:COMPUTERNAME)_MdmDiagnostics.zip" -Context $ctx

Write-Output "Cleanup the MdmDiagnostics zip from the device ..."
Remove-Item -Path "$($env:TEMP)\$($date)_$($env:COMPUTERNAME)_MdmDiagnostics.zip"

Write-Output "All done!"