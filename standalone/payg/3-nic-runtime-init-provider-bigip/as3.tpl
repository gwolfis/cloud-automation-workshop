{
	"class": "AS3",
	"action": "deploy",
	"persist": true,
	"declaration": {
		"schemaVersion": "3.0.0",
		"class": "ADC",
		"remark": "HTTPS App Service",
		"label": "HTTPS App Service",
		"Tenant_1": {
			"class": "Tenant",
			"HTTPS_Service": {
				"class": "Application",
				"template": "https",
				"serviceMain": {
					"class": "Service_HTTPS",
					"virtualAddresses": [
						"0.0.0.0"
					],
					"pool": "web_pool",
					"serverTLS": {
						"bigip": "/Common/clientssl"
					},
					"redirect80": true
				},
				"web_pool": {
					"class": "Pool",
					"remark": "Service Discovery Pool",
					"members": [{
						"addressDiscovery": "azure",
						"addressRealm": "private",
						"resourceGroup": "${resource_group_name}",
						"tagKey": "discovery",
						"tagValue": "${discovery}",
						"resourceType": "scaleSet",
						"servicePort": 80,
						"subscriptionId": "${subscription_id}",
						"updateInterval": 60,
						"useManagedIdentity": true
					}],
					"monitors": [
						"tcp"
					]
				}
			}
		}
	}
}