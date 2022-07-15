{
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "schemaVersion": "3.0.0",
        "class": "ADC",
        "remark": "Autoscale",
        "label": "Autoscale",
        "Tenant_2": {
            "class": "Tenant",
            "Shared": {
                "class": "Application",
                "template": "shared",
                "telemetry_local_rule": {
                    "remark": "Only required when TS is a local listener",
                    "class": "iRule",
                    "iRule": "when CLIENT_ACCEPTED {\n  node 127.0.0.1 6514\n}"
                },
                "telemetry_local": {
                    "remark": "Only required when TS is a local listener",
                    "class": "Service_TCP",
                    "virtualAddresses": [
                        "255.255.255.254"
                    ],
                    "virtualPort": 6514,
                    "iRules": [
                        "telemetry_local_rule"
                    ]
                },
                "telemetry": {
                    "class": "Pool",
                    "members": [
                        {
                            "enable": true,
                            "serverAddresses": [
                                "255.255.255.254"
                            ],
                            "servicePort": 6514
                        }
                    ],
                    "monitors": [
                        {
                            "bigip": "/Common/tcp"
                        }
                    ]
                },
                "telemetry_hsl": {
                    "class": "Log_Destination",
                    "type": "remote-high-speed-log",
                    "protocol": "tcp",
                    "pool": {
                        "use": "telemetry"
                    }
                },
                "telemetry_formatted": {
                    "class": "Log_Destination",
                    "type": "splunk",
                    "forwardTo": {
                        "use": "telemetry_hsl"
                    }
                },
                "telemetry_publisher": {
                    "class": "Log_Publisher",
                    "destinations": [
                        {
                            "use": "telemetry_formatted"
                        }
                    ]
                },
                "telemetry_traffic_log_profile": {
                    "class": "Traffic_Log_Profile",
                    "requestSettings": {
                        "requestEnabled": true,
                        "requestProtocol": "mds-tcp",
                        "requestPool": {
                            "use": "telemetry"
                        },
                        "requestTemplate": "event_source=\"request_logging\",hostname=\"$BIGIP_HOSTNAME\",client_ip=\"$CLIENT_IP\",server_ip=\"$SERVER_IP\",http_method=\"$HTTP_METHOD\",http_uri=\"$HTTP_URI\",virtual_name=\"$VIRTUAL_NAME\",event_timestamp=\"$DATE_HTTP\""
                    }
                },
                "telemetry_asm_security_log_profile": {
                    "class": "Security_Log_Profile",
                    "application": {
                        "localStorage": false,
                        "remoteStorage": "splunk",
                        "servers": [
                            {
                                "address": "255.255.255.254",
                                "port": "6514"
                            }
                        ],
                        "storageFilter": {
                            "requestType": "all"
                        }
                    }
                },
                "shared_pool": {
                    "class": "Pool",
                    "remark": "Service 1 shared pool",
                    "members": [
                        {
                            "servicePort": 80,
                            "serverAddresses": [
                                "10.1.3.102"
                            ]
                        }
                    ],
                    "monitors": [
                        "http"
                    ]
                }
            },
            "HTTPS_Service": {
                "class": "Application",
                "template": "https",
                "serviceMain": {
                    "class": "Service_HTTPS",
                    "virtualAddresses": [
                        "${vip-2}"
                    ],
                    "policyWAF": {
                        "use": "WAFPolicy"
                    },
                    "profileTrafficLog": {
                        "use": "/Tenant_2/Shared/telemetry_traffic_log_profile"
                    },
                    "pool": "/Tenant_2/Shared/shared_pool",
                    "securityLogProfiles": [
                        {
                            "bigip": "/Common/Log all requests"
                        },
                        {
                            "use": "/Tenant_2/Shared/telemetry_asm_security_log_profile"
                        }
                    ],
                    "serverTLS": {
                        "bigip": "/Common/clientssl"
                    },
                    "redirect80": true
                },
                "WAFPolicy": {
                    "class": "WAF_Policy",
                    "url": "https://raw.githubusercontent.com/F5Networks/f5-azure-arm-templates-v2/v1.4.0.0/examples/autoscale/bigip-configurations/Rapid_Deployment_Policy_13_1.xml",
                    "enforcementMode": "blocking",
                    "ignoreChanges": false
                }
            }
        }
    }
}