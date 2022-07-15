# Output

output "App_Services" {
  value = <<EOF

      bigip0-mgmt     : ${element(azurerm_network_interface.management.*.private_ip_address, 0)} => https://${element(azurerm_public_ip.mgmt_pip.*.ip_address, 0)}
      bigip1-mgmt     : ${element(azurerm_network_interface.management.*.private_ip_address, 1)} => https://${element(azurerm_public_ip.mgmt_pip.*.ip_address, 1)}
      application-vip : http://${azurerm_public_ip.alb_pip.ip_address}
      application-vip : https://${azurerm_public_ip.alb_pip.ip_address}
    EOF
}