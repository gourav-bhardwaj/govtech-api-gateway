#!/usr/bin/env groovy
import java.text.SimpleDateFormat
def date = new Date()
def sdf = new SimpleDateFormat("MM-dd-yyyy")
String BUILD_TIMESTAMP = sdf.format(date)
String version = env.BUILD_NUMBER
def jobnameparts = JOB_NAME.tokenize('/') as String[]
String jobName = jobnameparts[1]
String application = "${jobName}"
String branchName = "${env.BRANCH_NAME}"
String HELM_FILENAME = "deploy-${branchName}"

//Docker config env
String DOCKER_REGISTRY = "govtech-api-gateway"
String DOCKER_CREDENTIALS_ID = "USER_DOCKER_CREDENTIALS_ID"

pipeline {
  agent any
  tools {
    gradle 'mygradle'
  }
  stages {
    stage("GIT") {
       steps {
           step([$class: 'WsCleanup'])
           checkout scm
           sh 'mkdir -p helm-chart'
           dir('helm-chart') {
             git url: "https://github.com/gourav-bhardwaj/govtech-helm-chart-app.git", branch: 'dev', credentialsId: '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'
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
           BRANCH_NAME = readFile('.git/commit').trim()
           NAMESPACE = ""
           CHANNEL = ""
           KUBE_CONTEXT = ""
           KUBE_CREDENTIAL_ID = ""
           if (BRANCH_NAME == 'dev') {
           		NAMESPACE = "gv-tech"
		        CHANNEL = "dev"
		        KUBE_CONTEXT = ""
		        KUBE_CREDENTIAL_ID = ""
		        NEW_BRANCH_NAME = readFile('.git/commit').trim()
		        echo "********This is $NEW_BRANCH_NAME**************"
           } 
         }
       }
    }
    stage("Package and Build") {
      steps {
        script {
          sh "gradle clean build"
        }
      }
    }
    stage("Docker build & push") {
      steps {
        script {
          withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}", url: '') {
	        sh "docker build -t ${DOCKER_REGISTRY}/${application}:${BUILD_TIMESTAMP}.${version}.${BRANCH_NAME} ."
	        sh "docker push ${DOCKER_REGISTRY}/${application}:${BUILD_TIMESTAMP}.${version}.${BRANCH_NAME}"
	      }
        }
      }
    }
    stage("Helm Deploy") {
      steps {
        script {
          withCredentials([file(credentialsId: "${KUBE_CREDENTIAL_ID}", variable: 'KUBECONFIG_CONTENT')]) {
            sh "PWD"
            sh "ls -ltr"
            sh "helm upgrade --install --namespace ${NAMESPACE} ${jobName} helm-chart/spring-boot -f values/${HELM_FILENAME}.yaml --set image.tag=${BUILD_TIMESTAMP}.${version}.${BRANCH_NAME} --kubeconfig ${KUBECONFIG_CONTENT} --kube-context ${KUBE_CONTEXT} --debug --atomic"
          }
        }
      }
    }
  
  }
}

