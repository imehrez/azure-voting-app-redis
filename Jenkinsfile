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
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                // available as an env variable, but will be masked if you try to print it out any which way
                // note: single quotes prevent Groovy interpolation; expansion is by Bourne Shell, which is what you want
                sh 'echo $PASSWORD'
                // also available as a Groovy variable
                echo USERNAME
                // or inside double quotes for string interpolation
                echo "username is $USERNAME"
                }
                retry(3) {
                    sh './build.sh'
                }

                echo "GIT_COMMIT is ${env.GIT_COMMIT} build ID: ${env.BUILD_ID}"

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
