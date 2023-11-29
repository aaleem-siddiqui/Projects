# IoTDeviceReonboardingAutomation
**JIRA:** [OPS-259](google.com) <br />
**CREATED BY:** AALEEM SIDDIQUI

## DESCRIPTION
This pipeline automates the process of re-onboarding an IoT Device. 

## LINKS
[How to use the Automation](google.com) <br />
[Backend Documentation](google.com)

## USAGE
1. Navigate to the 'Run pipeline' page within this repository.
   - Build (on the left-hand side toolbar) > Pipelines > Run Pipeline
1. You will now enter the variables required for this pipeline. 
   - **IMEI:** Provide the IMEI of the IoT Device
   - **ICCID:** Provide the ICCID of the IoT Device
   - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster
   - **INSTANCE_NAME:** Provide the name of the Tenant
   - **NEW_INSTANCE_NAME:** Provide the name of the NEW Tenant. Leave this value empty if you are re-onboarding into the same tenant.
1. Once you've entered in these variables, you can hit the 'Run pipeline' button underneath the variables.
   - The pipeline should now trigger and you will see four stages (Factory reset, delete from kubernetes, delete from instance, and re-onboard IoT Device)
   - These stages will process in order, you may click on each stage to see it's status and to confirm that it is successful
   - If there are any errors returned in this automation, feel free to reach out to Aaleem Siddiqui
