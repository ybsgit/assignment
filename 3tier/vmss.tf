

resource "azurerm_linux_virtual_machine_scale_set" "myvmss" {
  name                = var.vmss_name 
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vmss_sku
  instances           = var.vmss_instances
  admin_username      = "adminuser"
  custom_data = base64encode(data.template_file.init.rendered)
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("myterrakey.pub")
  }

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer 
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.vmss_name}-nsg"
    primary = true

    ip_configuration {
      name      = "internal"
  /*     public_ip_address {
        name = "vmss-ip"
      }*/
      primary   = true
      subnet_id = azurerm_subnet.backend.id
      application_gateway_backend_address_pool_ids = [azurerm_application_gateway.main.backend_address_pool.*.id[0]]
    }

  }
}

resource "azurerm_monitor_autoscale_setting" "vmmss-autoscaling" {
  name                = "myAutoscaleSetting"
  resource_group_name =  azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.myvmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.myvmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.myvmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

}

data "template_file" "init" {
  template = "${file("init.tpl")}"
  vars = {
    dbpass = azurerm_key_vault_secret.vmpassword.value
    host = azurerm_mysql_flexible_server.mydb.fqdn
    user = azurerm_mysql_flexible_server.mydb.administrator_login
  }
}


resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.vmssnsg.id
}

resource "azurerm_network_security_group" "vmssnsg" {
  name                = "${var.vmss_name}-nsg"
  resource_group_name =  azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}


resource "azurerm_nat_gateway" "nat" {
  name                    = "nat-Gateway"
  resource_group_name =  azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_public_ip" "nat-ip" {
  name                = "nat-gateway-publicIP"
  resource_group_name =  azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}


resource "azurerm_subnet_nat_gateway_association" "nat-sub" {
  subnet_id      = azurerm_subnet.backend.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_nat_gateway_public_ip_association" "nat-to-ip" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat-ip.id
}