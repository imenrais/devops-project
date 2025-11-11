pipeline {
    agent any

    environment {
        SONARQUBE_ENV = credentials('sonarqube-token')
        SONAR_HOST_URL = 'http://sonarqube:9000'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = 'imenrais/devops-backend'
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo '📥 Cloning project from GitHub...'
                git branch: 'main', url: 'https://github.com/imenrais/devops-project.git'
            }
        }

        stage('Build with Maven') {
            steps {
                echo '⚙️ Building the project...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running SonarQube code analysis...'
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        mvn sonar:sonar \
                            -Dsonar.projectKey=devops-project \
                            -Dsonar.host.url=http://sonarqube:9000 \
                            -Dsonar.login=$SONARQUBE_ENV
			    -Dsonar.projectBaseDir=.
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    echo '⏳ Waiting for SonarQube quality gate...'
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Semgrep SAST Scan') {
            steps {
                echo '🔒 Running Semgrep SAST security scan...'
                sh '''
                    semgrep --config auto --error --json --output semgrep-report.json .
                '''
            }
            post {
                always {
                    echo '📦 Archiving Semgrep results...'
                    archiveArtifacts artifacts: 'semgrep-report.json', fingerprint: true
                }
                failure {
                    echo '❌ Semgrep found security issues! Build failed.'
                }
                success {
                    echo '✅ Semgrep scan completed successfully.'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing Docker image to Docker Hub...'
                script {
                    docker.withRegistry('', 'dockerhub-creds') {
                        sh 'docker push $IMAGE_NAME'
                    }
                }
            }
        }

        stage('Deploy Simulation') {
            steps {
                echo '🚀 Deployment simulation complete.'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
