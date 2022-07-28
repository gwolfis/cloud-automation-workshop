{
    "class": "AS3",
    "action": "patch",
    "persist": true,
    "schemaVersion": "3.29.0",
    "remark": "Add New Application",
    "id": "lab2:App_3",
    "patchBody": [
        {
            "op": "add",
            "path": "/lab_2/App_3",
            "value": {
                "class": "Application",
                "service": {
                    "class": "Service_HTTP",
                    "virtualAddresses": [
                        "${vip-5}"
                    ],
                    "pool": "/lab_2/Shared/shared_pool"
                }
            }
        }
    ]
}