/*
FILENAME: addUsers.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: Jenkins Job that automates a set of tasks that get run on an EC2 instance. With a provided CSV of user information, automates the task of adding them to a Client's Website.
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"

// needed for commenting job results on jira
env.JIRA_SITE = 'sm_genericClientName_com'


pipeline {
	parameters {
		// parameters defined in jenkins job
		string(defaultValue: '', description: 'Jira Ticket Number\n', name: 'JIRA')
		choice(choices: 'production\nuat\nquality_assurance', description: 'Choose stack\n', name: 'ENVIRONMENT')
		string(defaultValue: '', description: 'ID of the Client (for example: 12354678910)\n', name: 'CLIENT_ID')
		string(defaultValue: '', description: 'CSV File Name (for example: Users.csv)\n', name: 'CSVNAME')
	}

	agent {label 'generic_Agent_Label'}
	environment {
		// environment variables
		INTEGRATOR = ""
		KEY_ID = ""
		SECRET_KEY = ""
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
            try {
              currentBuild.displayName = "Build User: ${BUILD_USER}"
          	} 
          	catch(err) {
            		env.ASSIGNEE = env.ASSIGNEE.split(',')[1].minus("name=").trim()
            		currentBuild.displayName = "Build User: ${ASSIGNEE}"
          	}
						currentBuild.description = "JIRA : ${JIRA}"
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 1 ////////////////////////////////////////////////////////////

		stage('Download CSV from S3') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 1 *Downloading Users.csv file from S3*\n\n'

					echo '\n\n\n\nAdding WORKSPACE...'
					sh 'mkdir addUsers'
        			sh 'cp -av addUsersInWebsite/* addUsers/'
        			sh 'unzip addUsers/Users_creator.zip -d addUsers/'

        			echo '\n\n\n\nDOWNLOADING CSV FROM S3...'
        			sh """
        				set +x
                    	creds=\$(aws sts assume-role --role-arn=arn:aws:iam::account#:role/add-Users-role --role-session-name=genericSessionName)
                    	export AWS_ACCESS_KEY_ID=\$(echo \$creds | cut -d '"' -f 6 ); \
                    	export AWS_SECRET_ACCESS_KEY=\$(echo \$creds | cut -d '"' -f 10 ); \
                    	export AWS_SESSION_TOKEN=\$(echo \$creds | cut -d '"' -f 14 );
                    	set -x
               		    aws s3 ls s3://addUsers/csv/
               		    aws s3 cp s3://addUsers/csv/${CSVNAME} addUsers/Users_creator/
               		    ls -al addUsers/Users_creator/
                    	exit
                    EOF
                    """
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 2 ////////////////////////////////////////////////////////////

		stage('add Users') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 2 *Adding Users in Website*\n\n'

					if (ENVIRONMENT == 'production') {
								INTEGRATOR = "website_integrator"
						}
					if (ENVIRONMENT == 'uat') {
								INTEGRATOR = "uat_website_integrator"
						}
					if (ENVIRONMENT == 'quality_assurance') {
								INTEGRATOR = "quality_assurance_website_integrator"
						}

					withCredentials([usernamePassword(credentialsId: "${INTEGRATOR}", passwordVariable: 'secret_key', usernameVariable: 'key_id')]) {

						KEY_ID = env.key_id
						SECRET_KEY = env.secret_key

						echo '\n\n\n\nINSTALLING GO...'
						sh 'sudo apt install golang -y'

						echo '\n\n\n\nAdding Users...'
                    	sh """
               		       	cd addUsers/Users_creator
              	         	export GO111MODULE=on
           		         	go build
           		         	./Users_creator --stage=${params.ENVIRONMENT} --client-id=${params.CLIENT_ID.trim()} --filename=${params.CSVNAME.trim()} --key-id=${KEY_ID} --secret=${SECRET_KEY} 2>&1 | tee addUsers.log
           		         	exit
                  		EOF
                   		"""

                   		echo '\n\n\n\nCAPTURING SCRIPT OUTPUT'
                   		env.Log = sh(script:"cat addUsers/Users_creator/addUsers.log",returnStdout: true).toString()
                    }
				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'Whether you like it or not, the job has finished :|'
			cleanWs()
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		success {
			script {
				try {
        			comment = [body: "================ add Users JOB RESULTS: =================\n{code}${env.Log}{code}"]
        			jiraAddComment idOrKey: "${params.JIRA.trim()}", input: comment, auditLog: false
        			echo "Commenting the job results on ${params.JIRA.trim()}."
    			}
    			//if there's any errors in JIRA parameter, for example URL entered instead of KEY - comment won't be posted
    			catch (err) {
       				echo "Oopsie. The jira key was not specified correctly. Auto-comment won't be posted.    :("
       				println err
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
