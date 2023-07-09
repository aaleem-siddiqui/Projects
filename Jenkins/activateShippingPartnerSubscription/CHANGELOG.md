1.0
* Original Doc*

1.1
- I think this wasn't implimented into lower environments was because shipping partner activation doesn't work there (my guess)
- removed the deployment server dependency, full logs are now uploaded to s3:arn:aws:s3:::activateshippingpartnerlogs in AWSaccountNumber
- project files/scripts are held in repo together, not stored on deployment server
- improved date syntax on final log
- added cleanworkspace in post actions
- hidden credentials and secrets
