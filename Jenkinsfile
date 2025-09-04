pipeline {
    agent {
        docker { 
            image 'python:3.11' 
            args '-v /var/run/docker.sock:/var/run/docker.sock' // ใช้ Docker ของ host
        }
    }

    environment {
        SONARQUBE = credentials('sonar-token')   // token จาก Jenkins Credentials
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
                   sh '''
                   docker run --rm \
                       -v "$PWD:/usr/src" \
                       -w /usr/src \
                       sonarsource/sonar-scanner-cli \
                       -Dsonar.projectKey=fast-api-jenkins-sonarqube \
                       -Dsonar.sources=. \
                       -Dsonar.host.url=http://host.docker.internal:9001 \
                       -Dsonar.login=$SONARQUBE
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
                script {
                    // รัน container บน host และ bind 0.0.0.0 เพื่อเข้าถึงจาก browser
                    sh '''
                    docker run -d \
                        --name fastapi-app \
                        -p 8000:8000 \
                        fastapi-app:latest \
                        uvicorn app.main:app --host 0.0.0.0 --port 8000
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finished"
        }
    }
}
