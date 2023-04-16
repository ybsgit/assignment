variable "rg_name" {
  default = "3-tier"
}

variable "rg_location" {
  default = "eastus"
}

variable "vnet_name" {
  default = "vnet"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
}

variable "frontend_address_prefix" {
   default = ["10.0.0.0/24"]
}

variable "backeend_address_prefix" {
   default = ["10.0.1.0/24"]
}

variable "db_address_prefix" {
   default = ["10.0.2.0/24"]
}

variable "application_gateway_name" {
   default = "myAppGateway"
}

variable "mysql_server_name" {
  default = "mydb-fs"
}

variable "mysql_user_name" {
  default = "sqladmin"
}

variable "mysql_sku" {
  default =  "GP_Standard_D2ds_v4"
}


variable "vmss_name" {
  default = "vmss"
}
variable "vmss_sku" {
  default = "Standard_F2"
}

variable "vmss_instances" {
  default = 2
}

variable "source_image" {
  type = object({
    publisher = string
    offer      = string
    sku  = string
    version = string
  })
    default = {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku  = "18.04-LTS"
      version = "latest"
    }
}


variable "backend_address_pool_name" {
    default = "myBackendPool"
}

variable "frontend_port_name" {
    default = "myFrontendPort"
}

variable "frontend_ip_configuration_name" {
    default = "myAGIPConfig"
}

variable "http_setting_name" {
    default = "myHTTPsetting"
}

variable "listener_name" {
    default = "myListener"
}

variable "request_routing_rule_name" {
    default = "myRoutingRule"
}