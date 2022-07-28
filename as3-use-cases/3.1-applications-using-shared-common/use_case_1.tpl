{
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "3.0.0",
        "label": "LAB 1",
        "remark": "Two applications sharing a pool in /Common",
        "Common": {
            "class": "Tenant",
            "Shared": {
                "class": "Application",
                "template": "shared",
                "shared_pool": {
                    "class": "Pool",
                    "monitors": [
                        "http"
                    ],
                    "members": [
                        {
                            "servicePort": 80,
                            "serverAddresses": [
                                "${poolmember-1}"
                            ]
                        }
                    ]
                }
            }
        },
        "lab_1": {
            "class": "Tenant",
            "App_1": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTP",
                    "virtualAddresses": [
                        "${vip-1}"
                    ],
                    "pool": "/Common/Shared/shared_pool"
                }
            }
        },
        "lab_11": {
            "class": "Tenant",
            "App_2": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTPS",
                    "virtualAddresses": [
                        "${vip-2}"
                    ],
                    "pool": "/Common/Shared/shared_pool",
                    "serverTLS": "webtls"
                },
                "webtls": {
                    "class": "TLS_Server",
                    "certificates": [
                        {
                            "certificate": "webcert"
                        }
                    ]
                },
                "webcert": {
                    "class": "Certificate",
                    "certificate": {
                        "bigip": "/Common/default.crt"
                    },
                    "privateKey": {
                        "bigip": "/Common/default.key"
                    }
                }
            }
        }
    }
}