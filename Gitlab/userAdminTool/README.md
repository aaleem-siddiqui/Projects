# User Administration Tool
**JIRA:** [CDOP-284](https://www.atlassian.com/software/jira) | [CDOP-321](https://www.atlassian.com/software/jira) <br />
**CREATED BY:** AALEEM SIDDIQUI

## DESCRIPTION
This pipeline performs multiple operations relating to user administration:
- [Create a Single-Tenant User](https://www.atlassian.com/software/confluence)
- [Create a Multi-Tenant User](https://www.atlassian.com/software/confluence)
- [List all Tenants for User](https://www.atlassian.com/software/confluence)
- [Delete a User from a Tenant](https://www.atlassian.com/software/confluence)
- [Generate an Initial Sign-up Link for a User in a Tenant](https://www.atlassian.com/software/confluence)
- [Update a Users Password](https://www.atlassian.com/software/confluence)

## BACKEND
[Backend Documentation](https://www.atlassian.com/software/confluence)

## USAGE
1. Navigate to the 'Run pipeline' page within this repository.
   - Build (on the left-hand side toolbar) > Pipelines > Run Pipeline
1. You will now enter the variables required for your operation:
   - For creating a single-tenant user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
      - **ROOT_TENANT:** Provide the name of the tenant that you would like to add this user to. 
      - **FIRST_NAME:** Provide the users first name.
      - **LAST_NAME:** Provide the users last name.
      - **PASSWORD:** Provide the password the user will use to login. OPTIONAL: Will default to 'Firststart#123' if left empty.
      - **GROUP_ASSIGNMENT:** Provide the level of permissions that you would like to give the user in the new tenant.
   - For creating a multi-tenant user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
      - **ROOT_TENANT:** Provide the name of the new tenant that you would like to add this user to. 
      - **EXISTING_TENANTS:** Provide the names of the existing tenants that the user is associated with. **NOTE:** <u>IF YOU ARE MISSING A TENANT NAME THAT THE USER CURRENTLY HAS ACCESS TO, THEY WILL LOST THAT DURING PATCHING!</u>
      - **GROUP_ASSIGNMENT:** Provide the level of permissions that you would like to give the user in the new tenant.
   - For listing all tenants for a user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
   - For deleting a user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
      - **ROOT_TENANT:** Provide the name of the tenant that you would like to delete this user from. 
   - For generating an initial sign-up link for a user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
      - **ROOT_TENANT:** Provide the name of the tenant that the user signed up for. 
   - For patching the password of a user:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **USER_EMAIL:** Provide the users e-mail.
      - **ROOT_TENANT:** Provide the name of the tenant the user exists in. If the user is multi-tenant, provide any one of the names.
      - **PASSWORD:** Provide the password the user will use to login. OPTIONAL: Will default to 'Firststart#123' if left empty.
1. Once you've entered in these variables, you can hit the 'Run pipeline' button underneath the variables.
   - The pipeline should now trigger and you will see one stage: **userAdminTool**
   - You may click on this stage to see it's status.
