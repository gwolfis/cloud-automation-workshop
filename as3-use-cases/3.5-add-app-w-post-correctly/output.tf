# output.terraform

output "App_Services" {
  value = <<EOF

      bigip0-mgmt : ${data.azurerm_network_interface.bigip0_management.private_ip_address} => https://${data.azurerm_public_ip.bigip0_mgmt_pip.ip_address}
      bigip1-mgmt : ${data.azurerm_network_interface.bigip1_management.private_ip_address} => https://${data.azurerm_public_ip.bigip1_mgmt_pip.ip_address}
      vip-3-http  : ${local.setup.vips.vip-3} => http://${data.azurerm_public_ip.bigip0_ext_vpip_3.ip_address}
      vip-4-http  : ${local.setup.vips.vip-4} 
      vip-4-https : ${local.setup.vips.vip-4}
      vip-5-http  : ${local.setup.vips.vip-5}
      vip-6-http  : ${local.setup.vips.vip-6}
      poolmember-2: ${local.setup.web.poolmember-2}
    EOF
}