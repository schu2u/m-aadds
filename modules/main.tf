variable "AaddsAdminUserUpn" {}
variable "TenantId" {}
variable "AzureSubscriptionId" {}
variable "ManagedDomainName" {}
variable "ResourceGroupName" {}
variable "VnetName" {}
variable "AzureLocation" {}
variable "pw" {}
variable "Appid" {}
variable "thumb" {}

# Call Powershell.exe and pass in 'foo' and 'bar'
data "external" "azure_adds" {
  program = ["Powershell.exe", "./modules/AzureADDS.ps1"]

  query = {
    # Change the following values to match your deployment.
    AaddsAdminUserUpn = "${var.AaddsAdminUserUpn}"
    TenantId = "${var.TenantId}"
    AzureSubscriptionId = "${var.AzureSubscriptionId}"
    ManagedDomainName = "${var.ManagedDomainName}"
    ResourceGroupName = "${var.ResourceGroupName}"
    VnetName = "${var.VnetName}"
    AzureLocation = "${var.AzureLocation}"
    pw = "${var.pw}"
    Appid = "${var.Appid}"
    thumb = "${var.thumb}"

  }
}

output "vnetname" {
  value = "${data.external.azure_adds.result.vnetname}"
}

output "vnetid" {
  value = "${data.external.azure_adds.result.vnetid}"
}
