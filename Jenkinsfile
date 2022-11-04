GIT_SHA=$(shell git log --format=%h -1 .)
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
ECR_REGISTRY="242369466814.dkr.ecr.us-east-2.amazonaws.com"
ECR_IMAGE="${ECR_REGISTRY}/${PROJECT}:${GIT_SHA}"

// Outputs JSON consumable credentials
def assumeRole(String role = "role_to_be_assumed") {
  return sh(script: """
    aws sts assume-role \
      --role-arn ${role} \
      --query 'Credentials' \
      --role-session-name jenkins
  """, returnStdout: true)
}

def timestamp() {
  return sh(script: """
    date -u +"%Y%m%d_%H%M%SZ"
  """, returnStdout: true).trim()
}

pipeline {
  agent {
    kubernetes {
      label 'cicd-docker'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  priorityClassName: high-priority
  containers:
  - image: docker:20.10-dind
    name: dind
    ports:
    - containerPort: 2375
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ''
  - name: docker-client
    image: ubuntu:latest
    command:
    - cat
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
"""
    }
  }

  //triggers {
  //  cron('@weekly')
  //}

  environment {
    AWS_REGION = "us-east-2"
  }

  stages {
    stage('Install dependencies') {
      steps {
        container('docker-client') {
          sh 'env | sort'

          // Prerequisite packages for build
          sh 'apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gpg apt-transport-https ca-certificates curl unzip lsb-core git-core'

          // Docker client binary install
          sh 'mkdir -p /etc/apt/keyrings'
          sh 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
          sh 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null'
          sh 'apt-get update && apt-get install -y docker-ce-cli'

          // AWS Client Install - Necessary for docker login and assume role operations
          sh 'curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"'
          sh 'unzip awscliv2.zip && rm awscliv2.zip'
          sh './aws/install && rm -rf ./aws'
        }
      }
    }

    stage('Release') {
      steps {
        container('docker-client') {
          script {
            // Provi Prod Push Permissions
            jsonCreds = assumeRole("arn:aws:iam::242369466814:role/development-to-production-ecr")
            creds = readJSON text: "${jsonCreds}"
          }
          withEnv([
            "AWS_ACCESS_KEY_ID=${creds.AccessKeyId}",
            "AWS_SECRET_ACCESS_KEY=${creds.SecretAccessKey}",
            "AWS_SESSION_TOKEN=${creds.SessionToken}"
          ]) {
            sh "bash build-images.sh"
          }
        }
      }
    }
  }

  post {
    always {
      notifySlack()
    }
  }
}


def notifySlack() {
  def message = "jenkins-cicd\n${currentBuild.currentResult}: <${env.RUN_DISPLAY_URL}|${env.JOB_NAME}>"

  if (currentBuild.currentResult != "SUCCESS") {
    slackSend(color: "danger", message: message, channel: "#alerts-devops")
  }
}
