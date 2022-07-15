# Output

output "BIGIP_MGMT" {
    value = <<EOF

      f5vm0 : https://${element(azurerm_public_ip.mgmt_pip.*.ip_address, 0)}
      f5vm1 : https://${element(azurerm_public_ip.mgmt_pip.*.ip_address, 1)}
    EOF
}

output "SSH_Public_Key" {
    value = azurerm_ssh_public_key.f5_key.public_key
}