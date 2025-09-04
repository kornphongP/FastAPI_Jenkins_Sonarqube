pipeline {
    agent any  // ใช้ Jenkins node ที่มี Docker CLI

    environment {
        SONARQUBE = credentials('sonar-token')   // token จาก Jenkins Credentials
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kornphongP/FastAPI_Jenkins_Sonarqube.git'
            }
        }

        stage('Install Dependencies & Run Tests') {
            agent {
                docker {
                    image 'python:3.11'
                    args '-u root:root'   // รันเป็น root จะติดตั้ง pip ได้
                }
            }
            steps {
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
                sh 'pip install coverage pytest'
                sh 'PYTHONPATH=. pytest --cov=app tests/ --cov-report=xml:coverage.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // ใช้ Docker image ของ SonarScanner แยกออกจาก Python container
                    docker.image('sonarsource/sonar-scanner-cli').inside {
                        sh """
                            sonar-scanner \
                                -Dsonar.projectKey=fast-api-jenkins-sonarqube \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=http://host.docker.internal:9001 \
                                -Dsonar.login=${SONARQUBE}
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t fastapi-app:latest .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh 'docker stop fastapi-app || true'
                sh 'docker rm fastapi-app || true'
                sh 'docker run -d --name fastapi-app -p 8000:8000 fastapi-app:latest'
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finished"
        }
    }
}
