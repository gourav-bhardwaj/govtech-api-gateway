#!/usr/bin/env groovy
import java.text.SimpleDateFormat
def date = new Date()
def sdf = new SimpleDateFormat("MM-dd-yyyy")
String BUILD_TIMESTAMP = sdf.format(date)
String version = env.BUILD_NUMBER
def jobnameparts = JOB_NAME.tokenize('/') as String[]
String jobName = jobnameparts[0]
String application = "${jobName}"
String branchName = "${env.BRANCH_NAME}"
String HELM_FILENAME = "deploy-${branchName}"

//Docker config env -----
String DOCKER_REGISTRY = "govkumardocker"
String DOCKER_CREDENTIALS_ID = "USER_DOCKER_CREDENTIALS_ID"

pipeline {
    triggers {
        pollSCM("*/5 * * * *")
    }
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
'''
            defaultContainer 'golang'
        }
    }
  tools {
    gradle 'mygradle'
  }
  options { buildDiscarder(logRotator(numToKeepStr: '4')) }
  stages {
    stage("GIT") {
       steps {
           step([$class: 'WsCleanup'])
           checkout scm
           sh 'mkdir -p helm-chart'
           dir('helm-chart') {
             git url: "https://github.com/gourav-bhardwaj/govtech-helm-chart-app.git", branch: 'dev', credentialsId: 'govtech-git-cred-id'
           }
       }
    }
    stage("Env Variable") {
       steps {
         script {
           sh "git rev-parse --short HEAD > .git/commit"
           sh "basename `git rev-parse --show-toplevel` > .git/image"
           COMMIT = readFile('.git/commit').trim()
           echo "COMMIT ID is $COMMIT"
           sh 'git name-rev --name-only HEAD > GIT_BRANCH'
           sh 'cat GIT_BRANCH | cut -f3 -d "/" > test'
           BRANCH_NAME = readFile('test').trim()
           NAMESPACE = ""
           CHANNEL = ""
           KUBE_CONTEXT = ""
           KUBE_CREDENTIAL_ID = ""
           if (BRANCH_NAME == 'dev') {
           		NAMESPACE = "gv-tech"
		        CHANNEL = "dev"
		        KUBE_CONTEXT = "kubernetes-admin@kubernetes"
		        KUBE_CREDENTIAL_ID = "GOVTECH_KUBE_CRED"
		        NEW_BRANCH_NAME = readFile('test').trim()
		        echo "********This is $NEW_BRANCH_NAME**************"
	   } else if (BRANCH_NAME == 'pre-dev') {
           		NAMESPACE = "gov-tech-pre-dev"
		        CHANNEL = "pre-dev"
		        KUBE_CONTEXT = "kubernetes-admin@kubernetes"
		        KUBE_CREDENTIAL_ID = "GOVTECH_KUBE_CRED"
		        NEW_BRANCH_NAME = readFile('test').trim()
		        echo "********This is $NEW_BRANCH_NAME**************"
	   }
         }
       }
    }
    stage("Package and Build") {
      steps {
        script {
          sh "gradle clean build -x test"
        }
      }
    }
    stage("Docker build & push") {
      steps {
        container('docker') {
                    sh "docker build -t ${DOCKER_REGISTRY}/${application}:$BUILD_NUMBER ."
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_CREDENTIALS_ID', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin DOCKER_CREDENTIALS_ID"
                    }
                    sh "docker push ${DOCKER_REGISTRY}/${application}:$BUILD_NUMBER"
                }
      }
    }
    stage("Helm Deploy") {
      steps {
        script {
          withCredentials([file(credentialsId: "${KUBE_CREDENTIAL_ID}", variable: 'KUBECONFIG_CONTENT')]) {
            sh "pwd"
            sh "ls -ltr"
            sh "helm upgrade --install --namespace ${NAMESPACE} ${jobName} helm-chart/spring-boot -f values/${HELM_FILENAME}.yaml --set image.repository=${DOCKER_REGISTRY}/${application},image.tag=${BUILD_TIMESTAMP}.${version}.${BRANCH_NAME} --kubeconfig ${KUBECONFIG_CONTENT} --kube-context ${KUBE_CONTEXT} --debug --atomic"
	  }
        }
      }
    }
  
  }
}

