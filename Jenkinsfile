
pipeline {
    agent { label 'ubuntu-agent3' }

    stages {

        stage('Git Checkout') {
            steps {
                echo 'Checking out source code'
                checkout scm
            }
        }

        stage('Permission Audit') {
            steps {
                echo 'Starting Linux Permission Audit'

                sh '''
                    chmod +x scripts/permission_audit.sh
                    bash scripts/permission_audit.sh /var/log
                '''
            }
        }

        stage('Verify Report') {
            steps {
                sh '''
                    echo "Checking generated report"
                    ls -lh permission_audit_*.log
                '''
            }
        }

        stage('Archive Report') {
            steps {
                archiveArtifacts artifacts: 'permission_audit_*.log',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Permission Audit Pipeline SUCCESS'
        }

        failure {
            echo 'Permission Audit Pipeline FAILED'
        }
    }
}
