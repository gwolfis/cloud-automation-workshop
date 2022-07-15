#Azure Credentials
variable subscription_id     { default = "" }
variable client_id           { default = "" }
variable client_secret       { default = "" }
variable tenant_id           { default = "" }

# # Tmp file
# variable "tmpfile" {
#   description = "The tmp file in yaml format"
#   type        = string
#   default     = "files/tmp.yml"
# }

# tfvars input
variable "user_name" {}
variable "user_password" {}
variable "prefix" {}
variable "unique_string" {}
variable "location" {}

# BIGIP Instances
variable "default_instance_count" { default = 2 }

#Tags
variable "environment" { default = "azure" }
variable "service_discovery_value" { default = "production" }

#Networks
variable "cidr" {default = "10.0.0.0/16"}
variable "subnet_management" {
  type = list(string)
  default = ["10.0.0.0/24"]
}
variable "subnet_external" {
  type = list(string)
  default = ["10.0.1.0/24"]
}
variable "subnet_internal" {
  type = list(string)
  default = ["10.0.2.0/24"]
}

# BIGIP Image PAYG
variable "instance_type" { default = "Standard_DS3_v2" }
variable "image_name" { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable "product" { default = "f5-big-ip-best" }
variable "bigip_version" { default = "16.0.101000" }

#F5 Automation Toolchain

variable "DO_URL" { default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.27.0/f5-declarative-onboarding-1.27.0-6.noarch.rpm" }
variable "AS3_URL" { default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.34.0/f5-appsvcs-3.34.0-4.noarch.rpm" }
variable "TS_URL" { default = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.26.0/f5-telemetry-1.26.0-3.noarch.rpm" }
variable "INIT_URL" { default = "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.2.0/dist/f5-bigip-runtime-init-1.2.0-1.gz.run" }