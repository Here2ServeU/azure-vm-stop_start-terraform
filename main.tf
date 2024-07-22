
### `main.tf`

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-vm-scheduler"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "stvmstartstop"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "function-code"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "start_blob" {
  name                   = "start-vm.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${path.module}/functions/start_vm.zip"
}

resource "azurerm_storage_blob" "stop_blob" {
  name                   = "stop-vm.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "${path.module}/functions/stop_vm.zip"
}

resource "azurerm_function_app" "start_function" {
  name                       = "start-vm-function"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~2"

  app_settings = {
    "AzureWebJobsStorage"         = azurerm_storage_account.sa.primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "VM_IDS"                      = join(",", var.vm_ids)
    "AZURE_SUBSCRIPTION_ID"       = var.subscription_id
    "RESOURCE_GROUP"              = azurerm_resource_group.rg.name
  }
}

resource "azurerm_function_app" "stop_function" {
  name                       = "stop-vm-function"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~2"

  app_settings = {
    "AzureWebJobsStorage"         = azurerm_storage_account.sa.primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "VM_IDS"                      = join(",", var.vm_ids)
    "AZURE_SUBSCRIPTION_ID"       = var.subscription_id
    "RESOURCE_GROUP"              = azurerm_resource_group.rg.name
  }
}

resource "azurerm_logic_app" "start_logic_app" {
  name                = "start-vm-logic-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  workflow {
    definition = <<DEFINITION
    {
      "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {
          "Http": {
            "inputs": {
              "method": "POST",
              "uri": "${azurerm_function_app.start_function.default_hostname}/api/start_vm"
            },
            "runAfter": {},
            "type": "Http"
          }
        },
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "triggers": {
          "Recurrence": {
            "recurrence": {
              "frequency": "Day",
              "interval": 1,
              "schedule": {
                "hours": [5],
                "minutes": [27]
              }
            },
            "type": "Recurrence"
          }
        }
      }
    }
    DEFINITION
  }
}

resource "azurerm_logic_app" "stop_logic_app" {
  name                = "stop-vm-logic-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  workflow {
    definition = <<DEFINITION
    {
      "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {
          "Http": {
            "inputs": {
              "method": "POST",
              "uri": "${azurerm_function_app.stop_function.default_hostname}/api/stop_vm"
            },
            "runAfter": {},
            "type": "Http"
          }
        },
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "triggers": {
          "Recurrence": {
            "recurrence": {
              "frequency": "Day",
              "interval": 1,
              "schedule": {
                "hours": [7],
                "minutes": [45]
              }
            },
            "type": "Recurrence"
          }
        }
      }
    }
    DEFINITION
  }
}
