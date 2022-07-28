# output.terraform

output "App_Services" {
  value = <<EOF

      bigip0-mgmt : ${data.azurerm_network_interface.bigip0_management.private_ip_address} => https://${data.azurerm_public_ip.bigip0_mgmt_pip.ip_address}
      bigip1-mgmt : ${data.azurerm_network_interface.bigip1_management.private_ip_address} => https://${data.azurerm_public_ip.bigip1_mgmt_pip.ip_address}
      vip-1-http  : ${local.setup.vips.vip-1} => http://${data.azurerm_public_ip.bigip0_ext_vpip_1.ip_address}
      vip-2-http  : ${local.setup.vips.vip-2} => http://${data.azurerm_public_ip.bigip0_ext_vpip_2.ip_address}
      vip-2-https : ${local.setup.vips.vip-2} => https://${data.azurerm_public_ip.bigip0_ext_vpip_2.ip_address}
      poolmember-1: ${local.setup.web.poolmember-1}
    EOF
}