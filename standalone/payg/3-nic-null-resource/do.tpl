{
    "schemaVersion": "1.0.0",
    "class": "Device",
    "async": true,
    "label": "Onboard BIG-IP standalone 3nic",
    "Common": {
        "class": "Tenant",
        "hostname": "${hostname}.local",
        "dbVars": {
            "class": "DbVariables",
            "ui.advisory.enabled": true,
            "ui.advisory.color": "blue",
            "ui.advisory.text": "BIG-IP 3-NIC Stand-Alone PAYG",
            "config.allow.rfc3927": "enable"
        },
        "myDns": {
            "class": "DNS",
            "nameServers": [
                "168.63.129.16"
            ],
            "search": [
                "f5.com"
            ]
        },
        "myNtp": {
            "class": "NTP",
            "servers": [
                "pool.ntp.org"
            ],
            "timezone": "Europe/Amsterdam"
        },
        "${user_name}": {
            "class": "User",
            "userType": "regular",
            "password": "${user_password}",
            "partitionAccess": {
                "all-partitions": {
                    "role": "admin"
                }
            },
            "shell": "tmsh"
        },     
        "myProvisioning": {
            "class": "Provision",
            "ltm": "nominal",
            "asm": "nominal"
        },
        "external": {
            "class": "VLAN",
            "tag": 4094,
            "mtu": 1500,
            "interfaces": [
                {
                    "name": "1.1",
                    "tagged": false
                }
            ]
        },
        "external-localself": {
            "class": "SelfIp",
            "address": "${self_ip_external}/24",
            "vlan": "external",
            "allowService": "default",
            "trafficGroup": "traffic-group-local-only"
        },
        "internal": {
            "class": "VLAN",
            "tag": 4093,
            "mtu": 1500,
            "interfaces": [
                {
                    "name": "1.2",
                    "tagged": false
                }
            ]
        },
        "internal-localself": {
            "class": "SelfIp",
            "address": "${self_ip_internal}/24",
            "vlan": "internal",
            "allowService": "default",
            "trafficGroup": "traffic-group-local-only"
        }
    }
}