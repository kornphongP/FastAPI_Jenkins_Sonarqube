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
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
                sh 'pip install sonar-scanner coverage pytest'
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
                      -Dsonar.sources=. \
                      -Dsonar.host.url=http://host.docker.internal:9001 \
                      -Dsonar.token=sqp_24e637ccced59d7a8c88d123f73f731e9c30cc05
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
