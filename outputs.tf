# Output

output "App_Services" {
  value = <<EOF

      bigip0-mgmt : ${azurerm_network_interface.bigip0_management.private_ip_address} => https://${azurerm_public_ip.bigip0_mgmt_pip.ip_address}
      bigip1-mgmt : ${azurerm_network_interface.bigip1_management.private_ip_address} => https://${azurerm_public_ip.bigip1_mgmt_pip.ip_address}
      vip-0       : ${local.setup.vips.vip-0}
      vip-1       : ${local.setup.vips.vip-1} => http://${azurerm_public_ip.bigip0_ext_vpip_1.ip_address}
      vip-2       : ${local.setup.vips.vip-2} => http://${azurerm_public_ip.bigip0_ext_vpip_2.ip_address}
      vip-3       : ${local.setup.vips.vip-3} => http://${azurerm_public_ip.bigip0_ext_vpip_3.ip_address}
      vip-4       : ${local.setup.vips.vip-4} 
      vip-5       : ${local.setup.vips.vip-5}
      vip-6       : ${local.setup.vips.vip-6}
      vip-7       : ${local.setup.vips.vip-7}
      vip-8       : ${local.setup.vips.vip-8}
      vip-9       : ${local.setup.vips.vip-9}
      poolmember-1: ${local.setup.web.poolmember-1}
      poolmember-2: ${local.setup.web.poolmember-2}
    EOF
}