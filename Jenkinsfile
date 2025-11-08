pipeline {
    agent any

    stages {
        stage("Git Clone") {
            steps {
                script {
                    git credentialsId: 'GIT_HUB_CREDENTIALS', url: 'https://github.com/NadineMili/Devops.git'
                }
            }
        }

        stage('Maven Build') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    sh 'docker version'
                    sh 'docker build -t nadinemilli/achat .'
                    sh 'docker images'
                }
            }
        }

        stage("Docker Login") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }
        
        stage("Push Image to Docker Hub") {
            steps {
                sh 'docker push nadinemilli/achat:latest'
            }
        }

        stage("SSH Into k8s Server") {
            steps {
                script {
                    def remote = [:]
                    remote.name = 'vagrant'
                    remote.host = '192.168.1.18'
                    remote.user = 'vagrant'
                    remote.password = 'vagrant'
                    remote.allowAnyHosts = true

                    stage('Put config files into k8smaster') {
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/stage/app_deployment.yml', into: '.'
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/stage/app_servicce.yml', into: '.'
                        sshPut remote: remote, from: '/var/lib/jenkins/workspace/stage/db_deployment.yml', into: '.'
                    }

                    stage('Deploy') {
                         sshCommand remote: remote, command: "export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl apply -f app_deployment.yml"
                         sshCommand remote: remote, command: "export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl apply -f app_servicce.yml"
                         sshCommand remote: remote, command: "export KUBECONFIG=/etc/kubernetes/admin.conf && kubectl apply -f db_deployment.yml"
        }
                }
            }
        }
    }
}
