{
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "3.0.0",
        "label": "LAB 2",
        "remark": "Two applications sharing a pool",
        "lab_2": {
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
                                "${poolmember-2}"
                            ]
                        }
                    ]
                }
            },
            "App_1": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTP",
                    "virtualAddresses": [
                        "${vip-3}"
                    ],
                    "pool": "/lab_2/Shared/shared_pool"
                }
            },
            "App_2": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTPS",
                    "virtualAddresses": [
                        "${vip-4}"
                    ],
                    "pool": "/lab_2/Shared/shared_pool",
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