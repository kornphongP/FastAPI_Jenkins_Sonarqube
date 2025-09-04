pipeline {
    agent {
        docker { 
            image 'python:3.11' 
            args '-u 0 -v /var/run/docker.sock:/var/run/docker.sock'  // ✅ mount docker socket to run docker commands
        }
    }

    environment {
        SONARQUBE = credentials('sonar-token')   // ✅ token จาก Jenkins Credentials
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kornphongP/FastAPI_Jenkins_Sonarqube.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'python -m pip install --upgrade pip --break-system-packages'
                sh 'python -m pip install -r requirements.txt --break-system-packages'
                sh 'python -m pip install coverage pytest --break-system-packages'
            }
        }

        stage('Run Tests & Coverage') {
            steps {
                sh 'PYTHONPATH=. pytest --cov=app tests/ --cov-report=xml:coverage.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
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
                sh 'docker run -d -p 8000:8000 fastapi-app:latest'
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finished"
        }
    }
}
