pipeline {
    agent any

    environment {
        // IMPORTANT: Replace 'yourdockerhubuser' with your actual Docker Hub username
        DOCKER_IMAGE = 'vaishnavanand/gguf-endpoint'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // 1. Jenkins automatically pulls the latest code from your GitHub repository
                checkout scm
            }
        }

        stage('Build AI Image') {
            steps {
                echo "Building the Docker Image..."
                // 2. Jenkins uses your Dockerfile to compile everything into an image
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push to Registry') {
            steps {
                echo "Pushing Image to Docker Hub..."
                // 3. Jenkins securely logs into Docker Hub and uploads the finished image
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                echo "Triggering Ansible Deployment..."
                // 4. Jenkins grabs your secret AWS PEM key and runs your deploy.yml playbook
                withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key', keyFileVariable: 'AWS_KEY')]) {
                    sh """
                    cd infra/ansible
                    # We pass the securely injected AWS_KEY to ansible so it can access the ML Server
                    ansible-playbook -i inventory.ini deploy.yml --private-key \$AWS_KEY
                    """
                }
            }
        }
    }
    
    post {
        always {
            // 5. Cleanup: Logs out of Docker to ensure credentials don't linger on the server
            echo "Cleaning up workspace..."
            sh "docker logout"
            cleanWs()
        }
    }
}