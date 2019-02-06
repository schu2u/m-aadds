# Create a resource group

module "AADDS"
{
  source   = "./modules"
  VnetName     = "${var.VnetName}"
  AzureLocation = "${var.AzureLocation}"
  ResourceGroupName = "${var.ResourceGroupName}"
  AaddsAdminUserUpn = "${var.AaddsAdminUserUpn}"
  TenantId = "${var.TenantId}"
  AzureSubscriptionId = "${var.AzureSubscriptionId}"
  ManagedDomainName = "${var.ManagedDomainName}"
  pw = "${var.pw}"
  Appid = "${var.Appid}"
  thumb = "${var.thumb}"
}
