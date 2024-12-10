packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 1.0.0"
    }
  }
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

source "azure-arm" "linux_image" {
  client_id          = var.client_id
  client_secret      = var.client_secret
  tenant_id          = var.tenant_id
  subscription_id    = var.subscription_id
  managed_image_name = "hardened-linux-image-22-04"
  managed_image_resource_group_name = "myResourceGroup"
  location           = "East US"
  vm_size            = "Standard_DS1_v2"
  os_type            = "Linux"
  image_publisher    = "Canonical"
  image_offer        = "UbuntuServer"
  image_sku          = "22_04-lts"
}

build {
  sources = ["source.azure-arm.linux_image"]
 provisioner "file" {
    source      = "/provisioner.sh"     # Local file to upload
    destination = "/tmp/provisioner.sh" # Destination on the instance
  }

  provisioner "shell" {
    execute_command = "echo '{{user `ssh_password`}}' | sudo -S bash '{{.Path}}'"
    script          = "/tmp/provisioner.sh" # Execute the uploaded script
  }
  provisioner "shell" {
    script = "provisioner.sh"
  }
}
