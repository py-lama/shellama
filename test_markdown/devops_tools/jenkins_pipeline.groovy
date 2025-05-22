// Example Jenkins pipeline script for SheLLama DevOps tools testing

pipeline {
    agent {
        docker {
            image 'python:3.9-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
        }
    }
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        DOCKER_REGISTRY_CREDENTIALS = 'docker-registry-credentials'
        SHELLAMA_VERSION = '1.0.0'
        DEPLOY_ENV = 'staging'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1'
                sh 'ls -la'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'apt-get update && apt-get install -y --no-install-recommends git curl build-essential docker.io'
                sh 'pip install --no-cache-dir -r requirements.txt'
                sh 'pip install --no-cache-dir pytest pytest-cov flake8 black isort'
            }
        }
        
        stage('Code Quality') {
            parallel {
                stage('Linting') {
                    steps {
                        sh 'flake8 shellama'
                        sh 'black --check shellama'
                        sh 'isort --check-only --profile black shellama'
                    }
                }
                
                stage('Type Checking') {
                    steps {
                        sh 'pip install --no-cache-dir mypy'
                        sh 'mypy shellama'
                    }
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh 'pytest --cov=shellama --cov-report=xml --cov-report=term tests/unit/'
            }
            post {
                always {
                    junit 'test-reports/*.xml'
                    cobertura coberturaReportFile: 'coverage.xml'
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'pytest tests/integration/'
            }
        }
        
        stage('Ansible Tests') {
            steps {
                sh 'make ansible-test-all-syntax'
                sh 'make ansible-test-git-mock'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def shellama_image = docker.build("${DOCKER_REGISTRY}/pylama/shellama:${SHELLAMA_VERSION}", "-f Dockerfile .")
                    def shellama_latest = docker.build("${DOCKER_REGISTRY}/pylama/shellama:latest", "-f Dockerfile .")
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_REGISTRY_CREDENTIALS) {
                        def shellama_image = docker.image("${DOCKER_REGISTRY}/pylama/shellama:${SHELLAMA_VERSION}")
                        def shellama_latest = docker.image("${DOCKER_REGISTRY}/pylama/shellama:latest")
                        
                        shellama_image.push()
                        shellama_latest.push()
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                expression { DEPLOY_ENV == 'staging' }
            }
            steps {
                sh 'echo "Deploying to staging environment..."'
                sh 'ansible-playbook -i ansible/inventories/staging ansible/deploy.yml -e "version=${SHELLAMA_VERSION}"'
            }
        }
        
        stage('Deploy to Production') {
            when {
                expression { DEPLOY_ENV == 'production' }
                beforeInput true
            }
            input {
                message "Deploy to production?"
                ok "Yes, deploy it!"
                submitter "admin"
            }
            steps {
                sh 'echo "Deploying to production environment..."'
                sh 'ansible-playbook -i ansible/inventories/production ansible/deploy.yml -e "version=${SHELLAMA_VERSION}"'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build and deployment successful!'
            slackSend(color: 'good', message: "SheLLama ${SHELLAMA_VERSION} build and deployment successful!")
        }
        failure {
            echo 'Build or deployment failed!'
            slackSend(color: 'danger', message: "SheLLama ${SHELLAMA_VERSION} build or deployment failed!")
        }
    }
}
