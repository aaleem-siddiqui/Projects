/*
FILENAME: ElasticAlertsBackup.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: A Jenkins Job that runs on a schedule to backup rules from elastic into a bitbucket repository
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"

import groovy.json.*

pipeline {

	agent {label 'generic_Agent_Label'}
	environment {
		KEY = ""
		GIT_USER = ""
		GIT_PASS = ""
		DATE = ""
		BRANCH = "develop"
	}

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 12, unit: 'HOURS')
		timestamps()
	}

////////////////////////////////////////////////// STAGE 1 ////////////////////////////////////////////////

	stages {
		stage('GETTING genericServiceName RULES') {
			steps {
				script {
					echo '\n\n\n\nCOMMENCING STAGE 1 *GETTING genericServiceName RULES*\n\n'

					// pulling key jenkins credentials store
					withCredentials([string(credentialsId: 'Stored_Jenkins_Credentials', variable: 'KEY')]) {
						
						echo '\n\n\n\nRUNNING SCRIPT TO GET ALL genericServiceName RULES\n\n'

						// installing jq and providing correct permissions for script
						sh 'sudo apt-get install -y jq'
						sh 'chmod +x genericServiceName-backup/backup-scripts/get_rules_genericServiceName.sh'
						
						// executing script and passing API key
						sh "./genericServiceName-backup/backup-scripts/get_rules_genericServiceName.sh ${KEY}"

					}
				}
			}
		}


////////////////////////////////////////////////// STAGE 2 ////////////////////////////////////////////////

		stage('PUSHING TO BITBUCKET') {
			steps {
				script {
					echo '\n\n\n\nCOMMENCING STAGE 2 *PUSHING TO BITBUCKET*\n\n'
					withCredentials([usernamePassword(credentialsId: 'Stored_Jenkins_Credentials', passwordVariable: 'password', usernameVariable: 'username')]) {

						// getting date
                    	DATE = sh(script:"date '+%Y-%m-%d_%H-%M-%S'",returnStdout: true).toString()

						//storing username and password into environment variables
						GIT_USER = env.username
						GIT_PASS = env.password

						// pushing changes to bitbucket
						sh "git status"
						sh "git config --global user.name \"${GIT_USER}\""
					    sh "git config --global user.email \"admin@genericCompanyName.com\""
					    sh "git remote set-url origin https://${GIT_USER}:${GIT_PASS}@bit.genericCompanyName.com/repo/genericCompanyName.git"
					    sh "git reset --soft"
						sh "git checkout -b ${BRANCH}"
					    sh "git add ."
					    sh "git commit -m \"Backup Date: ${DATE}\"||:"
					    sh "git push --set-upstream origin ${BRANCH}"
					    sh "git push --tags"
				  	}
				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'One way or another, I have finished'
			// cleans the workspace
			cleanWs()
		}
	}
}
