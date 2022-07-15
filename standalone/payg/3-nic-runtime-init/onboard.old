#!/bin/bash -x

# NOTE: Startup Script is run once / initialization only (Cloud-Init behavior vs. typical re-entrant for Azure Custom Script Extension )
# For 15.1+ and above, Cloud-Init will run the script directly and can remove Azure Custom Script Extension 


mkdir -p  /var/log/cloud /config/cloud /var/config/rest/downloads


LOG_FILE=/var/log/cloud/startup-script.log
[[ ! -f $LOG_FILE ]] && touch $LOG_FILE || { echo "Run Only Once. Exiting"; exit; }
npipe=/tmp/$$.tmp
trap "rm -f $npipe" EXIT
mknod $npipe p
tee <$npipe -a $LOG_FILE /dev/ttyS0 &
exec 1>&-
exec 1>$npipe
exec 2>&1

mkdir -p /config/cloud
  
#curl -o /config/cloud/do_w_admin.json -s --fail --retry 60 -m 10 -L https://raw.githubusercontent.com/f5devcentral/terraform-azure-bigip-module/master/config/onboard_do.json


### write_files:
# Download or Render BIG-IP Runtime Init Config 

cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
---
runtime_parameters:
  - name: USER_NAME
    type: static
    value: ${user_name}
  - name: ADMIN_PASS
    type: static
    value: ${user_password}
  - name: HOST_NAME
    type: metadata
    metadataProvider:
      environment: azure
      type: compute
      field: name
  - name: SELF_IP_EXTERNAL
    type: static
    value: ${self_ip_external}
  - name: SELF_IP_INTERNAL
    type: static
    value: ${self_ip_internal}
  - name: EXT_VIP
    type: static
    value: ${ext_vip}
  - name: RESOURCE_GROUP_NAME
    type: url
    value: 'http://169.254.169.254/metadata/instance/compute?api-version=2020-09-01'
    query: resourceGroupName
    headers:
      - name: Metadata
        value: true
  - name: SUBSCRIPTION_ID
    type: url
    value: 'http://169.254.169.254/metadata/instance/compute?api-version=2020-09-01'
    query: subscriptionId
    headers:
      - name: Metadata
        value: true
  - name: REGION
    type: url
    value: 'http://169.254.169.254/metadata/instance/compute?api-version=2020-09-01'
    query: location
    headers:
      - name: Metadata
        value: true
pre_onboard_enabled:
  - name: provision_rest
    type: inline
    commands:
      - /usr/bin/setdb provision.extramb 500
      - /usr/bin/setdb restjavad.useextramb true
bigip_ready_enabled: []
extension_packages:
  install_operations:
    - extensionType: do
      extensionVersion: ${DO_VER}
      extensionUrl: ${DO_URL}
    - extensionType: as3
      extensionVersion: ${AS3_VER}
      extensionUrl: ${AS3_URL}
    - extensionType: ts
      extensionVersion: ${TS_VER}
      extensionUrl: ${TS_URL}
extension_services:
  service_operations:
    - extensionType: do
      type: inline
      value:
        schemaVersion: 1.0.0
        class: Device
        async: true
        label: Standalone 3NIC BIG-IP declaration for DO with PAYG
        Common: 
          class: Tenant
          dbVars:
            class: DbVariables
            ui.advisory.enabled: true
            ui.advisory.color: blue
            ui.advisory.text: "BIG-IP 3-NIC Stand-Alone PAYG"
            #config.allow.rfc3927: enable
          mySystem:
            autoPhonehome: true
            class: System
            hostname: '{{{HOST_NAME}}}.local'
          myProvisioning:
            class: Provision
            ltm: nominal
            asm: nominal
          myNtp:
            class: NTP
            servers:
              - pool.ntp.org
            timezone: Europe/Amsterdam
          myDNS:
            class: DNS
            nameServers:
              - 168.63.129.16
          '{{{USER_NAME}}}':
            class: User
            userType: regular
            password: '{{{ADMIN_PASS}}}'
            shell: bash
          external:
            class: VLAN
            tag: 4094
            mtu: 1500
            interfaces:
              - name: '1.1'
                tagged: false
          external-self:
            class: SelfIp
            address: '{{{SELF_IP_EXTERNAL}}}/24'
            vlan: external
            allowService: default
            trafficGroup: traffic-group-local-only
          internal:
            class: VLAN
            interfaces:
              - name: '1.2'
                tagged: false
            mtu: 1500
            tag: 4093
          internal-self:
            class: SelfIp
            address: '{{{SELF_IP_INTERNAL}}}/24'
            vlan: internal
            allowService: default
            trafficGroup: traffic-group-local-only
    - extensionType: as3
      type: inline
      value:
        schemaVersion: 3.0.0
        class: ADC
        remark: HTTPS App Service
        label: HTTPS App Service
        Tenant_1:
          class: Tenant
          HTTPS_Service:
            class: Application
            template: https
            serviceMain:
              class: Service_HTTPS
              virtualAddresses: 
                - '{{{EXT_VIP}}}'
              pool: web_pool
              serverTLS:
                bigip: /Common/clientssl
              redirect80: true
            web_pool:
              class: Pool
              remark: Service Discovery Pool
              members:
                - addressDiscovery: azure
                  addressRealm: private
                  resourceGroup: '{{{RESOURCE_GROUP_NAME}}}'
                  tagKey: 'discovery'
                  tagValue: '${discovery}'
                  resourceType: scaleSet
                  servicePort: 80
                  subscriptionId: '{{{SUBSCRIPTION_ID}}}'
                  updateInterval: 60
                  useManagedIdentity: true
              monitors:
                - http
post_onboard_enabled: []
EOF
# # Download
#PACKAGE_URL='https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.1.0/dist/f5-bigip-runtime-init-1.1.0-1.gz.run'
PACKAGE_URL='https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.4.0/dist/f5-bigip-runtime-init-1.4.0-1.gz.run'
for i in {1..30}; do
    curl -fv --retry 1 --connect-timeout 5 -L ${INIT_URL} -o "/var/config/rest/downloads/f5-bigip-runtime-init-1.4.0-1.gz.run" && break || sleep 10
done
# Install
bash /var/config/rest/downloads/f5-bigip-runtime-init-1.4.0-1.gz.run -- '--cloud azure'
# Run
f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml
