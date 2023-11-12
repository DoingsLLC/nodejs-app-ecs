pipeline {
    agent any

    parameters {
        choice(choices: ['apply', 'destroy'], description: 'Please enter your option or action', name: 'action')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('DOINGS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('DOINGS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/DoingsLLC/nodejs-app.git'
                }
            }
        }

        stage("terraform init") {
            steps {
                script {
                    sh "terraform init"
                }
            }
        }

        stage("terraform plan") {
            steps {
                script {
                    sh "terraform plan"
                }
            }
        }

        stage("terraform apply") {
            steps {
                script {
                    sh "terraform apply --auto-approve"
                }
            }
        }

        // Uncomment this stage if you want to deploy to EKS
        // stage("Deploy to EKS") {
        //     when {
        //         expression { params.apply }
        //     }
        //     steps {
        //         script {
        //             sh "aws eks update-kubeconfig --name eks_cluster"
        //             sh "kubectl apply -f deployment.yml"
        //         }
        //     }
        // }
    }
}
