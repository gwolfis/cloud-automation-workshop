# Module 3 - Day 1: Deploy and maintain Application Services

Provisioning of the BIG-IP cluster has been performed without the deployment of an application. During this module you will make use of Application Services Extension 3 (AS3) to deploy those applications and go through some known practices.

## Application Service EXtention 3 (AS3)

Application Services Extension 3 or AS3 is an F5 open-source tool which has been developed to deploy BIG-IP L4 - L7 application services via a declarative model. The declaration represents the BIG-IP configuration which is defined through the use of JSON schema. This declaration can include application services for one or more applications and declared to a BIG-IP via one REST-API call. Using the declarative automation model makes that the defined JSON schema can be reused and app services functionality can get deployed as a self-service.

FAST allows one to use the pre-canned templates which can be found on BIG-IP once the .rpm has been installed, but FAST delivers the liberty to create your own custom templates.

For those who are less familiar with AS3 or want a further reading: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/

[PREVIOUS](../module_2/task2_3.md)      [NEXT](../module_3/task3_1.md)
