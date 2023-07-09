/*
FILENAME: purgeMultipleSQSQueues.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: AWS does not provide the ability to purge more than one SQS queue at a time. This Jenkins job does that whilst providing the SQS Queue Name, ARN, or Queue URL.
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"
// needed for commenting job results on jira
env.JIRA_SITE = 'sm_genericCompanyName_com'

def loop_func(split_params) {
    for (int i = 0; i < split_params.size(); i++) {
        env."var_${i}" = split_params[i]
    }
}

pipeline {
	parameters {
		// parameters defined in jenkins job
		string(defaultValue: '', description: 'Jira Ticket Number\n', name: 'JIRA')
		choice(choices: 'Queue_ARNs\nQueue_URLs\nQueue_Names', description: 'Specify whether the provided list is of Queue Names, ARNs, or URLs.\n', name: 'QUEUE_TYPE')
		choice(choices: 'no\nyes', description: 'Specifiy whether or not you would like to Purge the Queues. If you choose no, it will perform a Dry-run and only display queue attributes.\n', name: 'PURGE_QUEUE')
		text(defaultValue: '', description: 'List the Queues. One Queue per line.\n', name: 'QUEUES')
		choice(choices: '\nus-east-1\nus-west-2', description: 'REQUIRED FOR QUEUE_NAMES TYPE ONLY. If you are providing the Queue URLs or ARNs, you can leave this field blank.\n', name: 'REGION')
		choice(choices: '\nAWSaccount1\nAWSaccount2\nAWSaccount3\nAWSaccount4\nAWSaccount5\nAWSaccount6\nAWSaccount7\nAWSaccount8', description: 'REQUIRED FOR QUEUE_NAMES TYPE ONLY. If you are providing the Queue URLs or ARNs, you can leave this field blank.\n', name: 'AWS_ACCOUNT')
	}

	agent {label 'generic_Agent_Label'}
	environment {
		// environment variables
		ACCOUNT_NUMBER = ""
		REPO = "REPO"
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
					// BUILD_USER_ID env var provided by https: // DOCUMENTATION_LINK_HERE.jenkins-ci.org/display/JENKINS/Build+User+Vars+Plugin
					script {
                        currentBuild.displayName = "Build User: ${BUILD_USER}"
						currentBuild.description = "JIRA : ${JIRA}"
					}
				}
			}
		}


//////////////////////////////////////////////////////////// STAGE 1 ////////////////////////////////////////////////////////////


		stage('Creating Queues File') {
			steps {
				// checking out repo with scripts related to job
				script {
					checkout([$class: 'Git',
                    	branches: [[name: "develop"]],
                    	doGenerateSubmoduleConfigurations: false,
                    	extensions: [[$class: 'WipeWorkspace']],
                    	submoduleCfg: [],
                    	userRemoteConfigs: [[credentialsId: 'Stored_Jenkins_Credentials',
                                        	name: 'origin',
                                        	url: "https://admin@bit.genericCompanyName.com/repo/${REPO}.git"]]
        			])

					// creating workspace directory, making all files retrieved from repo executable
        			sh 'mkdir purgeSQS'
        			sh 'cp -av purgeMultipleSQSQueues/* purgeSQS/'
        			sh 'chmod +x purgeSQS/*'

					def split_params = ""

					echo '\n\nCOMMENCING STAGE 1 *Creating Queues File*\n\n'
					echo '\n\nCREATING QUEUES.TXT FILE ON THE DEPLOYMENT SERVER.\n\n'


					// uses split loop to pull account number from URL, throws queues into text file and removes whitespaces.
					if (queue_type.equals('Queue_URLs') ) {

						split_params = "${params.QUEUES}".split('/')
						loop_func(split_params)
						ACCOUNT_NUMBER = "${env.var_3}"
						
						sh "echo '${params.QUEUES}' > purgeSQS/queues.txt"
						sh './purgeSQS/removeWhiteSpaces.sh purgeSQS/queues.txt'
					}
                    	
                    // uses split loop to pull account number from ARN, converts ARN to URL and throws queues into text file. removes whitespaces.
                   	if (queue_type.equals('Queue_ARNs') ) {

                   		split_params = "${params.QUEUES}".split(':')
						loop_func(split_params)
						ACCOUNT_NUMBER = "${env.var_4}"

						sh "echo '${params.QUEUES}' > purgeSQS/arns.txt"
						sh './purgeSQS/removeWhiteSpaces.sh purgeSQS/arns.txt'
						sh './purgeSQS/convertARNSToURLS.sh'
                    }


                    // if else to define account number from jenkins parameters, converts names into URLs and throws into text file. removes whitespaces.
                   	if (queue_type.equals('Queue_Names') ) {
                   		if (AWS_ACCOUNT == 'AWSaccount1') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount2') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount3') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount4') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount5') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
                    	if (AWS_ACCOUNT == 'AWSaccount6') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount7') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}
						if (AWS_ACCOUNT == 'AWSaccount8') {
							ACCOUNT_NUMBER = "AWSaccount#"
						}

						sh "echo '${params.QUEUES}' > purgeSQS/names.txt"
						sh './purgeSQS/removeWhiteSpaces.sh purgeSQS/names.txt'
						sh "./purgeSQS/convertNamesToURLS.sh ${params.REGION} ${ACCOUNT_NUMBER}"
 	               }
                    echo '\n\n============= LISTING THE CONTENTS OF QUEUES.TXT ==============\n'
                    sh 'cat purgeSQS/queues.txt'
                    echo '\n==============================================================\n\n'
				}
			}
		}
	

//////////////////////////////////////////////////////////// STAGE 2 ////////////////////////////////////////////////////////////


		stage('Getting Queue Attributes') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 2 *Getting Queue Attributes*\n\n'

					// assuming role in target account, using script to run loop on queue attributes.
                    sh """
                    	creds=\$(aws sts assume-role --role-arn=arn:aws:iam::${ACCOUNT_NUMBER}:role/purge-sqs-role --role-session-name=testing)
                    	export AWS_ACCESS_KEY_ID=\$(echo \$creds | cut -d '"' -f 6 ); \
                    	export AWS_SECRET_ACCESS_KEY=\$(echo \$creds | cut -d '"' -f 10 ); \
                    	export AWS_SESSION_TOKEN=\$(echo \$creds | cut -d '"' -f 14 );
                    	aws sts get-caller-identity
                    	./purgeSQS/getQueueAttributes.sh
                    	exit
                    EOF
                    """

                    echo '\n\n============= CURRENT NUMBER OF MESSAGES IN QUEUE AND IN FLIGHT ==============\n'
                    sh 'cat purgeSQS/output.txt'
                    env.Before = sh(script:"cat purgeSQS/output.txt",returnStdout: true).toString()
                    echo '================================================================================\n\n'
				}
			}
		}
	

//////////////////////////////////////////////////////////// STAGE 3 [purge queues] /////////////////////////////////////////////////////////////

		
		stage('Queue Purge') {
			steps {
				script {
					if (purge_queue.equals('yes') ) {
						echo '\n\nCOMMENCING STAGE 3 *Queue Purge*\n\n'

						// assuming role in target account, using script to run loop on queue purge.
						sh """
                    		creds=\$(aws sts assume-role --role-arn=arn:aws:iam::${ACCOUNT_NUMBER}:role/purge-sqs-role --role-session-name=genericRoleSessionName)
                    		export AWS_ACCESS_KEY_ID=\$(echo \$creds | cut -d '"' -f 6 ); \
                    		export AWS_SECRET_ACCESS_KEY=\$(echo \$creds | cut -d '"' -f 10 ); \
                    		export AWS_SESSION_TOKEN=\$(echo \$creds | cut -d '"' -f 14 );
                    		aws sts get-caller-identity
                    		./purgeSQS/purgeQueues.sh
                    		rm purgeSQS/output.txt
                    		./purgeSQS/getQueueAttributes.sh
                    		exit
                    	EOF
                    	"""

                    	echo '\n\n============= RECHECKING NUMBER OF MESSAGES IN QUEUE AND IN FLIGHT ==============\n'
                    	sh 'cat purgeSQS/output.txt'
                    	env.After = sh(script:"cat purgeSQS/output.txt",returnStdout: true).toString()
                    	echo '================================================================================\n\n'
					}
					else {
						echo '\n\n\n\n\nYOU HAVE CHOSEN NOT TO PURGE THE QUEUES. SKIPPING THIS STAGE.\n\n\n\n\n'
					}
				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'purge job finished... now say thank you.'
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		success {
			script {
				if (purge_queue.equals('yes') ) {
					try {
        				comment = [body: "=================== PURGE RESULTS: ====================\nBEFORE:{code}${env.Before}{code}\nAFTER:{code}${env.After}{code}"]
        				jiraAddComment idOrKey: "${params.JIRA.trim()}", input: comment, auditLog: false
        				echo "Commenting the job results on ${params.JIRA.trim()}."
    				}
    				//if there's any errors in JIRA parameter, for example URL entered instead of KEY - comment won't be posted
    				catch (err) {
        				echo "Oopsie. The jira key was not specified correctly. Auto-comment won't be posted.    :("
        				println err
    				}
    			}
    			else {
    				echo 'I guess you only chose to perform a Dry-run. You should be able to see the Queue attributes in the console output.'
    			}
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		failure {
			echo 'Job failed... that sucks.'
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		aborted {
			echo '... why would you do that'
		}
	}
}
