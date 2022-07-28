{
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "3.0.0",
        "label": "LAB 2",
        "remark": "Add another App to the same pool",
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
            "App_4": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTP",
                    "virtualAddresses": [
                        "${vip-6}"
                    ],
                    "pool": "/Common/Shared/shared_pool"
                }
            }
        }
    }
}