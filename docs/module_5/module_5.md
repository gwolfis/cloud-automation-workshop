# Module 5: Deploying App Services from UCS

In module 4 we started to make use of the VSC F5 Extension and experienced the power of the tool while using it to deploying FAST templates a connected BIG-IP.

## F5 Automation Config Converter (ACC)
Another capability of the F5 Extension is to support F5 Automation Config Converter (ACC). During this module you will learn how you can make use of ACC through the extension.

Configurations can be imported from UCS, SCF and .conf files and is able to convert to Declarative Onboarding (DO) and AS3. There are some restrictions which you can find in the docs.
An important note is that ACC does not support ASM and APM policy conversions.

More reading about ACC can be done here: https://clouddocs.f5.com/products/extensions/f5-automation-config-converter/latest/

## F5 Journeys
For those how are aware of **project Journeys** and are confused... Yes, project Journeys is a toolset which makes the convertion from object-based configured application services to AS3 declarations. 

Journeys uses ACC as the engine to convert, but it comes with more capabilities how you want to convert and where the result should get delivered including BIG-IP Next which is the next generation BIG-IP architecture and can be found at F5 VELOS and rSeries systems and (soon) BIG-IP NEXT Virtual Edtion.

This workshop does not have F5 Journeys in scope, but if you want to know more: https://github.com/f5devcentral/f5-journeys

[PREVIOUS](../module_4/task4_3.md)      [NEXT](../module_5/task5_1.md)