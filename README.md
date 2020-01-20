# Intune Win32 App - Windows Hybrid Runbook Worker
Win32 App Package designed for Microsoft Endpoint Manager (Intune) to deploy the Microsoft Monitoring Agent to Windows 10 clients, connect them to Log Analytics and register them as a Hybrid Runbook Worker in Azure Automation.

For more information, please refer to the blog post at https://srdn.io/2020/01/managing-your-modern-workplace-with-microsoft-endpoint-manager-and-azure-automation

## Requirements:
- Windows 10 devices managed with Microsoft Endpoint Manager (Intune)
- An Azure Subscription
- An Azure Automation account
- An Azure Log Analytics workspace
- The Azure Automation Solution added to the Log Analytics workspace

## Win32 App Configuration

### Custom build the Win32 app from the source
To connect devices to Log Analytics and register them as Hybrid Runbook Workers you need to pass along the workspace id, Azure Automation endpoint URL and necessary keys. With the prepackaged app you can pass these as parameters in the install cmdlet, but if you don't like to expose them there, another option is to embed them in the `Install-HybridWorker.ps1` PowerShell Script and repackage it.

### Using the prepackaged .intunewin Win32 app.
#### Program
Install command: PowerShell.exe -ExecutionPolicy Bypass -File "Install-HybridWorker.ps1 -workspaceId `<Log Analytics Workspace Id>` -workspaceKey `<Log Analytics Workspace Key>` -azAutomationUrl `<Azure Automation Url>` -azAutomationKey `<Azure Automation Primary Key>`
Uninstall command: PowerShell.exe -ExecutionPolicy Bypass -File "Uninstall-HybridWorker.ps1" -azAutomationUrl `<Azure Automation Url>` -azAutomationKey `<Azure Automation Primary Key>`
Install behavior: System
Device restart behavior: No specific action

### Detection rules:
When the device is successfully registered as Hybrid Runbook Worker, a new registry key will be present.

Rules format: Manually configure detection rules
Rule type: Registry
Key path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HybridRunbookWorker
Detection method: Key exists

## Win32 App Package creation cmdlet:
IntuneWinAppUtil.exe -c "source" -s "source\Setup.exe" -o "package"
