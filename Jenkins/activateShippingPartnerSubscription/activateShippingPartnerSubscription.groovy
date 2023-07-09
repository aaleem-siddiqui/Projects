/*
FILENAME: activateShippingPartnerSubscription.groovy 
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: Jenkins Job that automates a set of tasks that get run on an EC2 instance with specific parameters. Activates the ability for stores to use a Shipping partners.
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"


// variables used to e-mail job results to and post comments on jira
def emailTo="slack@genericClientName.slack.com"
env.JIRA_SITE = 'sm_genericClientName_com'


pipeline {
	parameters {
		// parameters defined in jenkins job
		string(defaultValue: '', description: 'Jira Ticket Number\n', name: 'JIRA')
		string(defaultValue: '', description: 'ID of the CLIENT\n', name: 'CLIENT_ID')
		text(defaultValue: '', description: 'List the Site IDs. One Site ID per line.\n', name: 'SITE_IDs')
	}

	agent {label 'generic_Agent_Label'}
	environment {
		// environment variables
		KEY_ID = ""
		SECRET_KEY = ""
		TOKEN = ""
		DATE = ""
	}

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 12, unit: 'HOURS')
		timestamps()
	}

	stages {
		stage('Log Build Details') {
			steps {
				wrap([$class: 'BuildUser']) {
					script {
            try {
              currentBuild.displayName = "Build User: ${BUILD_USER}"
          	} 
          	catch(err) {
            		env.ASSIGNEE = env.ASSIGNEE.split(',')[1].minus("name=").trim()
            		currentBuild.displayName = "Build User: ${env.ASSIGNEE}"
          	}
						currentBuild.description = "JIRA : ${params.JIRA}"
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 1 ////////////////////////////////////////////////////////////
	

		stage('Retrieve Token') {
			steps {
				script {
					echo '\n\n\n\nCOMMENCING STAGE 1 *Retrieve Token*\n\n'

					// pulling key_id and secret_key from jenkins credentials store
					withCredentials([usernamePassword(credentialsId: '[CREDENTIAL_ID_HERE]', passwordVariable: 'secret_key', usernameVariable: 'key_id')]) {

						// storing key_id and secret_key into environment variables
						KEY_ID = env.key_id
						SECRET_KEY = env.secret_key
						
						echo '\n\n\n\nSENDING REQUEST FOR TOKEN.\n\n'

						// sends post request for token
						TOKEN = sh(
										returnStdout: true, 
										script: """curl --location --request POST 'https://websitebackend.genericClientName.com/key/token' \
                                	            		--header 'Content-Type: application/json' \
                                    	        		--data-raw '{
                                        	        		"key_id": "${KEY_ID}",
                                            	    		"secret_key": "${SECRET_KEY}"
                                                			}'
                                    	""" 
                                    	).toString()
                    	
                    	echo '\nTOKEN RETRIEVED.\n\n'
                    	// lists the token for debugging purposes. this should be commented out unless used for troubleshooting.             
                    	// echo "LISTING THE TOKEN \n\n${TOKEN}\n\n"
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 2 ////////////////////////////////////////////////////////////
	

		stage('Creating Sites File') {
			steps {
				script {
					echo '\n\n\n\nCOMMENCING STAGE 2 *Creating Sites File*\n\n'
					echo 'CREATING SITES.TXT FILE ON JENKINS NODE\n\n'

					// creating workspace directory
					sh 'mkdir activateSP'
					sh 'cp -av activateShippingPartnerSubscription/* activateSP/'
					sh 'chmod +x activateSP/removeWhiteSpaces.sh'

					// echo's the site id's text box into sites.txt on the deployment server. removes whitespaces.
					sh "echo '${params.SITE_IDs}' > activateSP/sites.txt"
					sh './activateSP/removeWhiteSpaces.sh activateSP/sites.txt'

					// cats the sites.txt file in console output of jenkins job.
					echo '\n\n============= LISTING THE CONTENTS OF SITES.TXT ==============\n'
					sh 'cat activateSP/sites.txt'
					echo '\n==============================================================\n\n'

				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 3 ////////////////////////////////////////////////////////////
	
			
			stage('Activate ShippingPartner') {
			steps {
				script {
					echo '\n\n\n\nCOMMENCING STAGE 3 *Activate ShippingPartner*\n\n'
					// installing curl
					//sh 'sudo apt install curl -y'
                  	
          // curling nvm
					sh 'curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash'

					// setting up nvm for usage, setting node version, running ShippingPartner activation script
					sh """
						set +x
						export NVM_DIR="\$HOME/.nvm"
						[ -s "\$NVM_DIR/nvm.sh" ] && \\. "\$NVM_DIR/nvm.sh"
						[ -s "\$NVM_DIR/bash_completion" ] && \\. "\$NVM_DIR/bash_completion" 
						nvm install 10.15.3
						CLIENT_ID="${params.CLIENT_ID.trim()}" website_API_HOST="websitebackend.genericClientName.com" TOKEN="${TOKEN}" node activateSP/index.js 2>&1 | tee activateSP/activateSP.log
						set -x
						exit
					EOF
					"""
					echo '\n\n\n\nSCRIPT EXECUTION COMPLETE, CREATING THE LOG NOW\n'
					echo 'IF YOU WISH TO SEE FULL LOG DETAILS, LOGS ARE UPLOADED HERE IN AWS-ACCOUNT: s3://activateShippingPartnerlogs'

					// storing log as groovy var, so that it can be used in jira comment
					env.Log = sh(script:"cat activateSP/activateSP.log",returnStdout: true).toString()

					// creating more detailed log of script execution
					sh 'echo "\n\nThe Subscriptions.JSON payload used for this script is shown below.\n\n" >> activateSP/activateSP.log'
					sh 'cat activateSP/subscription.json >> activateSP/activateSP.log'
                   	sh 'echo "\n\nThe Sites the script was ran on are shown below.\n\n" >> activateSP/activateSP.log'
                   	sh 'cat activateSP/sites.txt >> activateSP/activateSP.log'
                   	DATE = sh(script:"date '+%Y-%m-%d_%H-%M-%S'",returnStdout: true).toString()
                   	sh "mv activateSP/activateSP.log activateSP/activateSP.log-${DATE}"

                   	echo '\n\n\n\nLOG CREATED, UPLOADING TO S3 NOW.\n'

                   	// uploading log to s3
                   	sh """
                   		set +x
                    	creds=\$(aws sts assume-role --role-arn=arn:aws:iam::account#:role/uploadShippingPartneractivationLogs --role-session-name=genericSessionName)
                    	export AWS_ACCESS_KEY_ID=\$(echo \$creds | cut -d '"' -f 6 ); \
                    	export AWS_SECRET_ACCESS_KEY=\$(echo \$creds | cut -d '"' -f 10 ); \
                    	export AWS_SESSION_TOKEN=\$(echo \$creds | cut -d '"' -f 14 );
                    	set -x
               		    aws s3 ls s3://activateShippingPartnerlogs
               		    aws s3 cp activateSP/activateSP.log-* s3://activateShippingPartnerlogs
                    	exit
                    EOF
                    """
				
				echo '\n\n\n\nOKAY, I THINK WE ARE DONE HERE.\n'
				echo 'COMMENCING POST-ACTIONS.'
				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////

	post {
		always {
			echo 'Activation job finished... now say thank you.'
			echo 'Posting the job results to the #generic slack channel. It is a public channel, you should join it if you havent already.'
			// cleans the workspace
			cleanWs()
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

		success {
			script {
				try {
        			comment = [body: "============= ShippingPartner ACTIVATION RESULTS: ==============\n{code}${env.Log}{code}"]
        			jiraAdpComment idOrKey: "${params.JIRA.trim()}", input: comment, auditLog: false
        			echo "COMMENTING THE JOB RESULTS ON ${params.JIRA.trim()}."
    			}
    			//if there's any errors in JIRA parameter, for example URL entered instead of KEY - comment won't be posted
    				catch (err) {
        				echo "Oopsie. The jira key was not specified correctly. Auto-comment won't be posted.    :("
        				println err
    				}
				}

    		// emails job results to #activate_ShippingPartner_tool slack channel and any other specified e-mails 	
			mail to: "${emailTo}",
				subject: "Activation complete: ${params.JIRA.trim()}",
				body: "The ShippingPartner Activation has completed successfully. View build results here: ${env.BUILD_URL}\n\nJIRA: ${JIRA}\nCLIENT ID: ${CLIENT_ID}\n\nShippingPartner ACTIVATION RESULTS:\n${env.Log}\n\nSITE IDs:\n${SITE_IDs}"
		}


//////////////////////////////////////////////////////////////////////////////////////////////////////////

		failure {
			script {
				// adps comment to jira
				try {
        			comment = [body: "ShippingPartner Activation Failed. View build results here:\n${env.BUILD_URL}"]
        			jiraAdpComment idOrKey: "${params.JIRA.trim()}", input: comment, auditLog: false
        			echo "COMMENTING THE JOB RESULTS ON ${params.JIRA.trim()}."
    			}
    			//if there's any errors in JIRA parameter, for example URL entered instead of KEY - comment won't be posted
    				catch (err) {
        				echo "Oopsie. The jira key was not specified correctly. Auto-comment won't be posted.    :("
        				println err
    				}
				}

    		// emails job results to #activate_ShippingPartner_tool slack channel and any other specified e-mails 	
			mail to: "${emailTo}",
				subject: "Build failed: ${params.JIRA.trim()}",
				body: "Build failed. ${env.BUILD_URL}"
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

		aborted {
			echo '... why would you do that'
		}
	}
}
