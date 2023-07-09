/*
FILENAME: getLogsFromMongoDB.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: gets relevant mongoDB logs from an EC2 instance required for tickets created with mongoDB support


CHANGELOG:
 - Added JIRA function to post a comment in JIRA with a link directly to the file in the S3 bucket
 - Removed  servers from dropdown as they are now in DocDB, moved job out of test folder in jenkins
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"

// variable for jira post
env.JIRA_SITE= 'sm_generic_com'

pipeline {
	parameters {
		// parameters defined in jenkins job
		string(defaultValue: '', description: 'Jira Ticket Number\n', name: 'JIRA')
		choice(choices: 'instance1\ninstance2\ninstance3\ninstance4\ninstance5\ninstance6\ninstance7\ninstance8\ninstance9\ninstance10\ninstance11\ninstance12\ninstance13\ninstance14\ninstance16\ninstance17\ninstance18\ninstance19\ninstance20\ninstance21\ninstance22\ninstance23\ninstance24\ninstance25\ninstance26\ninstance27', description: 'Choose Database\n', name: 'DATABASE')
		choice(choices: '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24\n25\n26\n27\n28\n29\n30', description: 'How many days worth of logs would you like?\n', name: 'DAYS')
		choice(choices: 'yes\nonly metrics', description: 'Include full diagnostic data directory?\n', name: 'DIAGNOSTIC_DATA')
	}

	agent {label 'generic_Agent_Label'}
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
                        currentBuild.displayName = "Build User: ${BUILD_USER}"
						currentBuild.description = "JIRA : ${JIRA}"
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 1 ////////////////////////////////////////////////////////////

		stage('AWSCLI Pre-check') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 1 *AWSCLI Pre-check*\n\n'
					sshagent(credentials : ['Stored_Jenkins_Credentials']) {

						// installing AWSCLI if it hasn't been installed already

						sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /
               		         echo "\n\nINSTALLING THE AWSCLI IF IT HASN'T BEEN INSTALLED ALREADY..."
               		         apt install awscli -y
               		         echo "\n\nTHIS IS THE CURRENT VERSION OF AWSCLI INSTALLED ON THIS DEVICE..."
               		         aws --version
               		         echo "\n\n"
               		         exit
                    	EOF
                    	'''
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 2 ////////////////////////////////////////////////////////////

		stage('get Logs') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 2 *get Logs*\n\n'

					def diagnostic_data = ""
					if (DIAGNOSTIC_DATA == 'yes')
						{
							diagnostic_data = 'yes'
						}

					sshagent(credentials : ['Stored_Jenkins_Credentials']) {
					
						// locates the diagnostic.data directory and stores in variable
						env.DiagnosticDataPath = sh(
                  			script: "export PATH=/home/ubuntu/.local/bin:$PATH; \
                    			ssh -T -o StrictHostKeyChecking=no root@${DATABASE} \" \
   	        					locate -b diagnostic.data; \"", 
                   				returnStdout: true
                    		).toString()


						// copying mongodblogs to newly created temporary directory
						sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /
               		         echo "\n\nCREATING TEMPORARY DIRECTORIES..."
               		         mkdir getLogs
               		         mkdir /getLogs/Logs
               		         echo "\n\nFINDING LOGS AND COPYING THEM THEM TO TEMPORARY DIRECTORY..."
               		         echo "\nATTEMPTING TO LOCATE LOGS IN /mongologs DIRECTORY"
               		         find /mongologs -name "mongodb.log*" -type f -mtime -${DAYS} -exec cp -p -n {} getLogs/Logs \\;
               		         echo "\nATTEMPTING TO LOCATE LOGS IN /mongodblogs DIRECTORY"
               		         find /mongodblogs -name "mongodb.log*" -type f -mtime -${DAYS} -exec cp -p -n {} getLogs/Logs \\;
               		         echo "\nATTEMPTING TO LOCATE LOGS IN /data DIRECTORY"
               		         find /data -name "mongodb.log*" -type f -mtime -${DAYS} -exec cp -p -n {} getLogs/Logs \\;
               		         cd ${DiagnosticDataPath}
               		         find . -name "mongodb.log*" -type f -mtime -${DAYS} -exec cp -p -n {} /getLogs/Logs \\;
               		         echo "\n\n\n"
               		         exit
                    	EOF
                    	'''

                    	// if diagnostic parameter is equal to yes, get full directory. else get only metrics.
                    	if (diagnostic_data.equals('yes') ) {
                    		sh '''
                   	         	export PATH=/home/ubuntu/.local/bin:$PATH
               		         	ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         	cd /
               		         	echo "\n\nCREATING DIAGNOSTIC.DATA FOLDER IN TEMPORARY DIRECTORY..."
               		         	mkdir /getLogs/Diagnostic.Data
               		         	cd ${DiagnosticDataPath}
               		         	echo "\nCOPYING ALL FILES FROM DIAGNOSTIC.DATA TO TEMPORARY DIRECTORY..."
               		         	cp -p * /getLogs/Diagnostic.Data
               		         	echo "\n\n"
               		         	exit
                    		EOF
                    		'''
                    	} else {
                    		sh '''
                   	         	export PATH=/home/ubuntu/.local/bin:$PATH
               		         	ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         	cd /
               		         	echo "\n\nCREATING METRICS FOLDER IN TEMPORARY DIRECTORY..."
               		         	mkdir /getLogs/metrics
               		         	cd ${DiagnosticDataPath}
               		         	echo "\n\nCOPYING METRICS TO TEMPORARY DIRECTORY..."
               		         	find . -name "metrics.*" -type f -mtime -${DAYS} -exec cp -p -n {} /getLogs/metrics/ \\;
               		         	echo "\n\n\n"
               		         	exit
                    		EOF
                    		'''
                    	}                   	
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 3 ////////////////////////////////////////////////////////////

		stage('Mongo Diagnostic') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 3 *Mongo Diagnostic*\n\n'
					sshagent(credentials : ['Stored_Jenkins_Credentials']) {
						
                    	// downloading mdiag.sh from the S3 bucket and running it. Copying the results to the same temporary directory.
                    	sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /
               		         echo "\n\nDOWNLOADING mdiag.sh FROM S3..."
               		         aws s3 cp s3://team_name-mongologs/mdiag/mdiag.sh .
               		         chmod +x mdiag.sh
               		         echo "\n\nRUNNING mdiag.sh..."
               		         ./mdiag.sh
               		         exit
                    	EOF
                    	'''
                        sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /
               		         echo "\n\nCOPYING THE RESULTS OF mdiag.sh TO THE TEMPORARY DIRECTORY..."
               		         mkdir mongoDiagnostics
               		         mv /tmp/mdiag-* mongoDiagnostics/
               		         find /mongoDiagnostics -name "mdiag*.json" -type f -mmin -2 -exec cp -p -n {} getLogs/ \\;
               		         echo "\n\n\n"
               		         exit
                    	EOF
                    	'''
					}
				}
			}
		}

//////////////////////////////////////////////////////////// STAGE 4 ////////////////////////////////////////////////////////////

		stage('Upload to S3') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 4 *Upload to S3*\n\n'
					sshagent(credentials : ['Stored_Jenkins_Credentials']) {

                    	// creating a tarball of everything in the directory, as well as listing the contents of the tarball
                    	sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /getLogs
               		         echo "\n\nCREATING THE TARBALL NOW..."
               		         tar czvf "MongoDBLogs-$(date '+%Y-%m-%d_%H-%M-%S')-${DATABASE}.tgz" *
               		         echo "\n\nTARBALL CREATED. LISTING THE CONTENTS OF THE TARBALL TO DOUBLE-CHECK..."
               		         tar tzvf MongoDBLogs*
               		         echo "\n\n\n"
               		         exit
                    	EOF
                    	'''
                      
                        // save filename to variable
                        env.s3filename = sh(
                            script: "export PATH=/home/ubuntu/.local/bin:$PATH; \
                                ssh -T -o StrictHostKeyChecking=no root@${DATABASE} \" \
                                ls /getLogs/MongoDBLogs* | xargs -n 1 basename; \"", 
                                returnStdout: true
                            ).toString()

                    	// uploading everything in the temporary folder to s3
                    	sh '''
                   	         export PATH=/home/ubuntu/.local/bin:$PATH
               		         ssh -T -o StrictHostKeyChecking=no root@${DATABASE} << EOF
               		         cd /
               		         echo "\n\nLISTING THE CONTENTS OF THE S3 BUCKET..."
               		         aws s3 ls s3://team_name-mongologs
               		         echo "\n\nUPLOADING THE NEWLY CREATED TARBALL TO THE S3 BUCKET...\n"
               		         aws s3 cp /getLogs/MongoDBLogs* s3://mongologs
               		         echo "\nUPLOAD COMPLETE. YOU CAN FIND THE TARBALL IN S3 IN AWS_ACCOUNT HERE: s3://mongologs" 
               		         echo "\nREMOVING THE TEMPORARY DIRECTORY..."
               		         rm -r getLogs/
               		         echo "\nTHE DIRECTORY HAS BEEN REMOVED...\n"
               		         exit
                    	EOF
                    	'''
					}
				}
			}
		}			
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'The Job has been completed... now say thank you.'
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		success {
            script {
                echo '\nJOB SUCCESS :)\n'
                // add comment to JIRA
                try {
                    comment = [body: "Jenkins build:     ${env.BUILD_URL}\nMongo logs file in S3:     https://s3.console.aws.amazon.com/s3/object/mongologs?region=us-east-1&prefix=${env.s3filename}"]
                    jiraAddComment idOrKey: "${params.JIRA.trim()}", input: comment, auditLog: false
                    echo "Posting link to file in S3 bucket as a comment in JIRA: ${params.JIRA.trim()}"
                }
                catch (err) {
                    echo "POSTING TO JIRA NO WORKY :("
                    println err
                }
            }
        }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		failure {
			echo 'JOB FAILURE. SOMETHING WENT WRONG :('
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		aborted {
			echo 'JOB ABORTED. SOMETHING WENT WRONG :('
		}
	}
}
