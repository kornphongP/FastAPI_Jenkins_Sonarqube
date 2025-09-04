pipeline {
    agent {
        docker { 
            image 'python:3.11' 
            args '-v /var/run/docker.sock:/var/run/docker.sock'
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
                sh 'python -m pip install sonar-scanner coverage pytest --break-system-packages'
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
                   sh '''
                   sonar-scanner \
                      -Dsonar.projectKey=fast-api-jenkins-sonarqube \
                      -Dsonar.sources=app \
                      -Dsonar.host.url=http://host.docker.internal:9001 \
                      -Dsonar.token=$SONARQUBE
                   '''
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
