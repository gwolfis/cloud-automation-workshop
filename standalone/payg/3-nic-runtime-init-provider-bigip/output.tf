# output "server_pupIP" {
#   description = "Server public IP"
#   value       = "https://${azurerm_public_ip.alb_pip.ip_address}"
# }

output "SSH_Public_Key" {
    value = azurerm_ssh_public_key.f5_key.public_key
}

output "BIGIP_MGMT_IP" {
    value = "https://${azurerm_public_ip.mgmt_pip.ip_address}"
}

output "App_Public_IP" {
    value = "https://${azurerm_public_ip.ext_vpip.ip_address}"
}