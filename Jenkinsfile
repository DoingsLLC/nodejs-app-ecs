pipeline {
    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')
    }

    environment {
        ACR_NAME = "doingsacr"
        registryUrl = "doingsacr.azurecr.io"
        IMAGE_NAME = "nodejswebapp"
        IMAGE_TAG = "v1"
        registryCredential = "doingsacr-credential"
    }

    stages {
        stage('SCM Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/DoingsLLC/nodejs-app.git']]])
            }
        }

        stage('Run Sonarqube') {
            environment {
                scannerHome = tool 'ibt-sonarqube'
            }
            steps {
                withSonarQubeEnv(credentialsId: 'ibt-sonar', installationName: 'IBT sonarqube') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    def dockerImage = docker.build("${registryUrl}/${IMAGE_NAME}:${IMAGE_TAG}", '.')
                }
            }
        }

        stage('Upload Image to ACR') {
            steps {
                script {
                    docker.withRegistry("https://${registryUrl}", registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}
