pipeline {
    agent any
    
    /*
    environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
    }
    */

    stages {
        stage('Build') {
            steps {

                //Add the commit ID and build number to the title of the UI
                text="GIT_COMMIT is ${env.GIT_COMMIT} build ID: ${env.BUILD_ID}" 
                sh 'sed -i "s/^TITLE.*/TITLE = ${text}/" ./azure-vote/azure-vote/config_file.cfg'
 
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_ID', passwordVariable: 'ACR_PASSWORD')]) {
                    retry(3) {
                        sh './build.sh'
                    }
                }

            }
        } 


        stage('Test') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    sh './test.sh'
                }

                input "Does the staging environment look ok?"
            }
        }

        stage('Deploy') {

            when {
              expression {
                currentBuild.result == null || currentBuild.result == 'SUCCESS' 
              }
            }

            steps {
                retry(3) {
                    sh './deploy.sh'
                }
            }
        
        }
    }

    post {
        always {
            echo 'This will always run'
            //deleteDir() /* clean up our workspace */
        }
        success {
            echo 'This will run only if successful'
            slackSend channel: '#devops-testing',
                  color: 'good',
                  message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
