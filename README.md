# Workshop - Deploying Cloud and Automate with F5 BIG-IP

**This is a community based project As such, F5 does not provide any offical support for this project**

This workshop is intended to learn what it takes to deploy F5 BIG-IP into cloud through the use of automation and maintain it throughout its ADC lifecycle.

The tasks include provisioning BIG-IPs via Terraform into Azure, build the BIG-IPs with declarative onboarding (DO) deploy and maintain application services through AS3 templates and using Telemetry Streaming to get visible what gets consumed by applications.

## What you will learn:
Partipants will gather insights which are usefull to understand what decisions you need to take and the power of the tools being used.

## How to use
You can dowload this repo and start playing around on your own or follow the flow and go through the tasks.

**********************************
## Table of Contents
**********************************

**[Getting Started](docs/Getting_Started.md)**

**[Module 1 - Starting the lab environment](docs/module_1/module_1.md)**

 * **[Task 1.1 - Explore and start the lab environment for UDF user](docs/module_1/task1_1.md)**

**[Module 2 - Day 0: Provision BIG-IP into Cloud through Automation](docs/module_2/module_2.md)**

 * **[2.1 - Automation through Terraform](docs/module_2/task2_1.md)**
 * **[2.2 - Automated BIG-IP Design Deployment](docs/module_2/task2_2.md)**
 * **[2.3 - Exploring BIG-IP in Azure](docs/module_2/task2_3.md)**

**[Module 3 - Day 1: Deploy and maintain Application Services](docs/module_3/module_3.md)**

 * **[3.1 - Applications using shared /Common](docs/module_3/task3_1.md)**
 * **[3.2 - Deploy multiple application in one tenant](docs/module_3/task3_2.md)**
 * **[3.3 - Use of Patch](docs/module_3/task3_3.md)**
 * **[3.4 - Add application with POST](docs/module_3/task3_4.md)**
 * **[3.5 - Add applications with POST Correctly](docs/module_3/task3_5.md)**
 * **[3.6 - Deleting Application Services](docs/module_3/task3_6.md)**
 * **[3.7 - Module 3: Use of AS3 Conclusion and Summary](docs/module_3/task3_7.md)**

**[Module 4 - Day 1: Using F5 Application Services Templates (FAST)](docs/module_4/module_4.md)**

 * **[4.1 - Deploy Applications with FAST via the GUI](docs/module_4/task4_1.md)**
 * **[4.2 - Create multiple apps with FAST via API](docs/module_4/task4_2.md)**
 * **[4.3 - Modify applications through FAST](docs/module_4/task4_3.md)**

**[Module 5: Deploying App Services from UCS](docs/module_5/module_5.md)**

 * **[5.1 - Convert object-based BIG-IP configurations into AS3 declarations](docs/module_5/task5_1.md)**

**[Module 6 - Day 2 Operations](docs/module_6/module_6.md)**
 
 * **[6.1 - BIG-IP Visibility and Analytics with Telemetry Streaming](docs/module_6/task6_1.md)**
 * **[6.2 - BIG-IP Failover Testing](docs/module_6/task6_2.md)**

**********************************