pipeline {
    agent any


stages {
    stage('dev infrastructure') {
        when {
            branch 'dev'
        }
        steps {
            script {
                sh 'terraform init'
                sh 'terraform plan -var-file=dev.tfvars'
            }
        }
    }

    stage('Staging infrastructure') {
        when {
            branch 'staging'
        }
        steps {
            script {
                sh 'terraform init'
                sh 'terraform plan -var-file=test.tfvars'
            }
        }
    }

    stage('Production infrastructure') {
        when {
            branch 'master'
        }
        steps {
            script {
                sh 'terraform init'
                sh 'terraform plan -var-file=prod.tfvars'
            }
        }
    }
}
}
