pipeline {
    agent any

    environment {
        // Credentials IDs (must match Jenkins credentials)
        GITHUB_TOKEN = credentials('github-cred')
        SONAR_TOKEN = credentials('sonarqube-token')

        // Tool names (must match Manage Jenkins → Tools)
        JAVA_HOME = tool(name: 'jdk17', type: 'jdk')
        MAVEN_HOME = tool(name: 'maven', type: 'maven')
        PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/imenrais/devops-project.git', credentialsId: 'github-cred'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=devops-project -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh '''
                    docker build -t imenrais/backend:latest .
                    echo "$GITHUB_TOKEN" | docker login ghcr.io -u imenrais --password-stdin
                    docker tag imenrais/backend:latest ghcr.io/imenrais/backend:latest
                    docker push ghcr.io/imenrais/backend:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Build and deployment succeeded 🎉'
        }
        failure {
            echo 'Something went wrong ❌'
        }
    }
}

