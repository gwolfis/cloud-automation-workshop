# output.terraform

output "App_Services" {
  value = <<EOF

      bigip0-mgmt : ${data.azurerm_network_interface.bigip0_management.private_ip_address} => https://${data.azurerm_public_ip.bigip0_mgmt_pip.ip_address}
      bigip1-mgmt : ${data.azurerm_network_interface.bigip1_management.private_ip_address} => https://${data.azurerm_public_ip.bigip1_mgmt_pip.ip_address}
      vip-6-http  : http://${local.setup.vips.vip-6}
      poolmember-2: ${local.setup.web.poolmember-2}
    EOF
}