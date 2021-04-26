pipeline{
  environment {
    registry = "madhupixiee/nodejs-helloworld"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  agent any
 
    stages {
        stage('Build'){
          tools {
       // I hoped it would work with this command...
       nodejs 'nodejs_happy'
   }
            steps{
             script{
                  sh 'npm install'
                }
            }
        }
        stage('Building image') {
          tools {
       // I hoped it would work with this command...
       dockerTool 'default'
   }
            steps{
                script {
                  sh 'docker start relaxed_lamport'
                  dockerImage = docker.build registry + ":latest"
                }
             }
          }
          stage('Push Image') {
            tools {
       // I hoped it would work with this command...
       dockerTool 'default'
   }
              steps{
                  script 
                    {
                        docker.withRegistry( '', registryCredential ) {
                            dockerImage.push()
                        }
                   } 
               }
            }
        stage('Deploying into k8s'){
            steps{
                 script 
                    {
                       sh 'kubectl apply -f deployment.yaml'
                        }
            }
        }
    }
}
