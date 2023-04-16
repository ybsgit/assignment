resource "azurerm_mysql_flexible_server" "mydb" {
  name                   =  var.mysql_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.mysql_user_name
  administrator_password = azurerm_key_vault_secret.vmpassword.value
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.dbnet.id
  sku_name               =  var.mysql_sku
  zone = 1
}

resource "random_id" "kvname" {
  byte_length = 5
  prefix = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv1" {
  depends_on = [ azurerm_resource_group.rg ]
  name                        = random_id.kvname.hex
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
    storage_permissions = [
      "Get",
    ]
  }
}


resource "random_password" "vmpassword" {
  length = 10
  special = false
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "sqlpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [ azurerm_key_vault.kv1 ]
}