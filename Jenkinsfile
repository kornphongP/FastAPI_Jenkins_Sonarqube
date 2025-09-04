pipeline {
    agent {
        docker { 
            image 'python:3.11' 
            args '-u root:root'
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
                sh 'pip install coverage pytest'
            }
        }


        stage('Run Tests & Coverage') {
            steps {
                sh 'PYTHONPATH=. pytest --cov=app tests/ --cov-report=xml:coverage.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {  // ✅ ชื่อ SonarQube server ที่ตั้งค่าใน Jenkins
                    sh 'sonar-scanner -Dsonar.projectKey=fast-api-jenkins-sonarqube -Dsonar.sources=app -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONARQUBE'
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
