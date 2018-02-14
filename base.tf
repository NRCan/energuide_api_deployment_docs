resource "azurerm_resource_group" "base" {
  name     = "aci-prod"
  location = "west us"
}

resource "azurerm_container_group" "base" {
  name                = "aci-nrcan"
  location            = "${azurerm_resource_group.base.location}"
  resource_group_name = "${azurerm_resource_group.base.name}"
  ip_address_type     = "public"
  os_type             = "linux"

  container {
    name   = "nrcan-api"
    image  = "${var.container_image}"
    cpu    = "0.5"
    memory = "1.0"
    port   = "3000"

  environment_variables {
    NRCAN_COLLECTION_NAME="${var.NRCAN_COLLECTION_NAME}"
    NRCAN_DB_CONNECTION_STRING="${var.NRCAN_DB_CONNECTION_STRING}"
    NRCAN_DB_NAME="${var.NRCAN_DB_NAME}"
    NRCAN_ENGINE_API_KEY="${var.NRCAN_ENGINE_API_KEY}"
  }
 }
}

