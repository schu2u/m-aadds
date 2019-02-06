# Read the JSON payload from stdin
$jsonpayload = [Console]::In.ReadLine()

# Convert JSON to a string
$json = ConvertFrom-Json $jsonpayload

$AaddsAdminUserUpn = $json.AaddsAdminUserUpn
$TenantId = $json.TenantId
$AzureSubscriptionId = $json.AzureSubscriptionId
$ManagedDomainName = $json.ManagedDomainName
$ResourceGroupName = $json.ResourceGroupName
$VnetName = $json.VnetName
$AzureLocation = $json.AzureLocation
$pw = $json.pw
$appid = $json.appid
$thumb - $json.thumb

# Create the service AAD application

 $apppw =  ConvertTo-SecureString -String $pw -AsPlainText -Force
 $cred = New-Object System.Management.Automation.PSCredential ($Appid,$apppw)
Connect-AzAccount -Credential $cred -ServicePrincipal -Tenant $TenantId -WarningAction SilentlyContinue -Subscription $AzureSubscriptionId | Out-Null

# Connect to your Azure AD directory.
Connect-AzureAD -Tenantid $TenantId -ApplicationID $Appid -CertificateThumbprint $thumb | Out-Null

$SP = get-azureadserviceprincipal -SearchString "domain"

  if($SP.appid -like "*2565bd9d-da50-47d4-8b85-4c97f669dc36*"){
    }
  elseif($SP.appid -notlike "*2565bd9d-da50-47d4-8b85-4c97f669dc36*"){
  $AzureADSP = New-AzureADServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"}


# Create the delegated administration group for AAD Domain Services.
$ADGroup = New-AzureADGroup -DisplayName "AAD DC Administrators" -Description "Delegated group to administer Azure AD Domain Services" -SecurityEnabled $true -MailEnabled $false -MailNickName "AADDCAdministrators"

# First, retrieve the object ID of the newly created 'AAD DC Administrators' group.
$GroupObjectId = Get-AzureADGroup -Filter "DisplayName eq 'AAD DC Administrators'" | Select-Object ObjectId

# Now, retrieve the object ID of the user you'd like to add to the group.
$UserObjectId = Get-AzureADUser -Filter "UserPrincipalName eq '$AaddsAdminUserUpn'" | Select-Object ObjectId

# Add the user to the 'AAD DC Administrators' group.
$AzureGroupMember = Add-AzureADGroupMember -ObjectId $GroupObjectId.ObjectId -RefObjectId $UserObjectId.ObjectId

# Register the resource provider for Azure AD Domain Services with Resource Manager.
$AADRegister = Register-AzResourceProvider -ProviderNamespace Microsoft.AAD

<# Create the resource group.
New-AzureRmResourceGroup `
  -Name $ResourceGroupName `
  -Location $AzureLocation
#>

# Create the dedicated subnet for AAD Domain Services.
 $AaddsSubnet = New-AzVirtualNetworkSubnetConfig -Name DomainServices -AddressPrefix 10.0.0.0/24

 $WorkloadSubnet = New-AzVirtualNetworkSubnetConfig -Name Workloads -AddressPrefix 10.0.1.0/24

# Create the virtual network in which you will enable Azure AD Domain Services.
 $Vnet=New-AZVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $AzureLocation -Name $VnetName -AddressPrefix 10.0.0.0/16 -Subnet $AaddsSubnet,$WorkloadSubnet -Force
 $vnetname = $VNet.name
 $vnetid = $Vnet.Id
# Enable Azure AD Domain Services for the directory.
$ADDSDomain = New-AzResource -ResourceId "/subscriptions/$AzureSubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.AAD/DomainServices/$ManagedDomainName" -Location $AzureLocation -Properties @{"DomainName"=$ManagedDomainName; "SubnetId"="/subscriptions/$AzureSubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$VnetName/subnets/DomainServices"} -ApiVersion 2017-06-01 -Force -WarningAction SilentlyContinue | Out-Null

# Write output to stdout
 Write-Output "{ ""vnetname"" : ""$vnetname"", ""vnetid"" : ""$vnetid""}"
