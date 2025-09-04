pipeline {
    agent any  // ใช้ Jenkins node ที่มี Docker CLI

    environment {
        SONARQUBE = credentials('sonar-token')   // Jenkins Credentials สำหรับ SonarQube token
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'feature/sonarqube-test', url: 'https://github.com/kornphongP/FastAPI_Jenkins_Sonarqube.git'
            }
        }

        stage('Install Dependencies & Run Tests') {
            agent {
                docker {
                    image 'python:3.11'
                    args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'  // รันเป็น root + DinD
                }
            }
            steps {
                // ติดตั้ง dependencies
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
                sh 'pip install coverage pytest'
                
                // รัน unit test และ generate coverage report
                sh 'PYTHONPATH=. pytest --cov=app tests/ --cov-report=xml:coverage.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // ใช้ SonarScanner container แยกออกจาก Python container
                    docker.image('sonarsource/sonar-scanner-cli').inside {
                        sh """
                            sonar-scanner \
                                -Dsonar.projectKey=fast-api-jenkins-sonarqube \
                                -Dsonar.sources=app \
                                -Dsonar.host.url=http://host.docker.internal:9001 \
                                -Dsonar.login=${SONARQUBE} \
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // รอผล Quality Gate จาก SonarQube
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
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
                // stop & remove container เดิมถ้ามี
                sh 'docker stop fastapi-app || true'
                sh 'docker rm fastapi-app || true'

                // รัน container ใหม่
                sh '''
                    docker run -d \
                        --name fastapi-app \
                        -p 8081:8000 \
                        fastapi-app:latest \
                        uvicorn app.main:app --host 0.0.0.0 --port 8000
                '''
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finished"
        }
    }
}
