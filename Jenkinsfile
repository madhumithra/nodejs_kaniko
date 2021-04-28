pipeline {
  //commnet added by Animesh
agent {
        kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: test-odu
    label : jenkins
spec:
  securityContext:
    runAsUser: 10000
    runAsGroup: 10000
  containers:
  - name: jnlp
    image: 'jenkins/jnlp-slave:4.3-4'
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
  - name: yair
    image: us.icr.io/dc-tools/security/yair:1
    command:
    - cat
    tty: true
    imagePullPolicy: Always
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-1534f90c9330d40486136b2997e7972a79a69baf
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    volumeMounts:
      - name: regsecret
        mountPath: /kaniko/.docker
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  - name: openshift-cli
    image: openshift/origin-cli:v3.11.0
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  volumes:
  - name: regsecret
    projected:
      sources:
      - secret:
          name: regsecret
          items:
            - key: .dockerconfigjson
              path: config.json
  imagePullSecrets:
  - name: oduregsecret
  - name: regsecret
"""
        }
    }
  environment {
    
     /* -----------DevOps Commander  created env variables------------ */
	
	DOCKER_URL= "us.icr.io/dc-tools"
DOCKER_CREDENTIAL_ID= "dc-docker-6110"
OPENSHIFT_URL= "https://c103-e.us-south.containers.cloud.ibm.com:31018"
OPENSHIFT_CREDENTIAL_ID= "dc-openshift-6110"
SONARQUBE_URL= "https://sonarqube-3-6.container-crush-02-4044f3a4e314f4bcb433696c70d13be9-0000.eu-de.containers.appdomain.cloud/"
SONARQUBE_CREDENTIAL_ID= "dc-sonarqube-6110"
CLAIR_URL= "https://clair-3-3.container-crush-02-4044f3a4e314f4bcb433696c70d13be9-0000.eu-de.containers.appdomain.cloud/"
CLAIR_CREDENTIAL_ID= "dc-clair-6110"
NAMESPACE= "estore"
INGRESS= "verizon-poc-1615357584710-f72ef11f3ab089a8c677044eb28292cd-0000.sjc03.containers.appdomain.cloud"
	
	/* -----------DevOps Commander  created env variables------------ */

          VERSION="1-SNAPSHOT"

        /* Parameters for Docker image that will be built and deployed */
        /* REGISTRY_USERNAME provided via a Jenkins secret
         * REGISTRY_PASSWORD provided via a Jenkins secret
         */
        REGISTRY_NAME="us.icr.io/dc-tools"
	//REGISTRY_NAME="odureg.azurecr.io"
        REGISTRY_SECRET="odu-registry"
        DOCKER_IMAGE="lnk"
        DOCKER_TAG="$BUILD_NUMBER"
       
  }
 
  stages {
    
     /* stage('Build'){
        tools {
           nodejs 'nodejs_happy'
           }
            steps{
             script{
                  sh 'sudo npm install'
                }
            }
        }*/

        stage ('Build: Docker') {
            steps {
                container('kaniko') {
                    /* Kaniko uses secret 'regsecret' declared in the POD to authenticate to the registry and push the image */
                    sh 'pwd && ls -l && df -h && cat /kaniko/.docker/config.json && /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=${REGISTRY_NAME}/${DOCKER_IMAGE}:${DOCKER_TAG}'
                }
            }
        }
        stage ('Secure: Image scan - Clair') {
            steps {
                container('yair') {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIAL_ID}", usernameVariable: 'REGISTRY_USERNAME', passwordVariable: 'REGISTRY_PASSWORD')]) {
                        script {
                            catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { /* Avoid the stage being FAILURE if Clair founds vulnerabilities above acceptable threshold. That will be calculated later in the gate */
                              //  sh 'yair.py --clair ${CLAIR_URL} --registry ${REGISTRY_NAME} --username ${REGISTRY_USERNAME} --password ${REGISTRY_PASSWORD} --no-namespace ${DOCKER_IMAGE}:${DOCKER_TAG}'
				 sh 'wget https://github.com/optiopay/klar/releases/download/v2.4.0/klar-2.4.0-linux-amd64'
				 sh 'mv klar-2.4.0-linux-amd64 klar'
				 sh 'chmod 755 klar'
		                 sh 'export CLAIR_ADDR=${CLAIR_URL} && export DOCKER_PASSWORD=${REGISTRY_PASSWORD} && export DOCKER_USER=${REGISTRY_USERNAME} && ./klar ${DOCKER_URL}/${DOCKER_IMAGE}:${DOCKER_TAG}  '
                            }
                        }
                    }
                }
            }
            post {
                always {
                    sh 'rm -rf $WORKSPACE/reports/clair && mkdir -p $WORKSPACE/reports/clair'
           //         sh 'cp clair-results.json $WORKSPACE/reports/clair'
                }
            }
        }		

        


    }
}

