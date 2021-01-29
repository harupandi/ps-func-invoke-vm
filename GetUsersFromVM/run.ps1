using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Log in using Service Principal
# For reference on how to create a Service Principal please visit: https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-5.4.0
# You'll need the following App Settings/Environment Variables: applicationId, secret, tenantId
$applicationId = [System.Environment]::GetEnvironmentVariable('applicationId')
$rawSecret = [System.Environment]::GetEnvironmentVariable('secret')

# Converting the secret to a SecureString as the credentials object needs it that way
$secret = ConvertTo-SecureString -String $rawSecret -AsPlainText -Force
$tenantId = [System.Environment]::GetEnvironmentVariable('tenantId')

# Setting up the credentials
$credentials = New-Object -TypeName System.Management.Automation.PSCredential($applicationId, $secret)

# Log in command with the credentials from above
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId -Verbose

# Setting the subscription to use, use the subscription name
set-AzContext -SubscriptionName '<subscription name here>' -Verbose

# Get the output from the Invoke command and store it in the $output variable
# Replace values for Resource Group and VM name
# We run script.ps1 found in the top-level directory of this repo
$output = Invoke-AzVMRunCommand -ResourceGroupName '<RG name here>' -VMName '<VM name here>' -CommandId 'RunPowerShellScript' -ScriptPath 'script.ps1' -Verbose

Write-Output $output.Value.Message

# Setting the Invoke command's output as the response body
$body = $output.Value.Message

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})