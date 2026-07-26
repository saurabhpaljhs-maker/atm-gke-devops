pipeline {
    agent any

    environment {
        GCP_PROJECT_ID   = "your-gcp-project-id"       // apna actual project ID daalna
        REGION           = "asia-south1"
        AR_REPO          = "atm-project-repo"
        APP_NAME         = "atm-project-app"
        IMAGE_URL        = "${REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${AR_REPO}/${APP_NAME}:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('MySonarQubeServer') {
                        def scannerHome = tool 'SonarScanner'
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=ATM-Project -Dsonar.sources=."
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_URL} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                // HIGH/CRITICAL vulnerabilities pe pipeline fail karo - security gate
                sh "trivy image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_URL} || true"
                // NOTE: abhi exit-code 1 ko '|| true' se ignore kar rahe (demo ke liye),
                // production mein '|| true' hatana taaki genuinely fail ho jaaye
            }
        }

        stage('Auth to GCP & Push') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY_FILE')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GCP_KEY_FILE
                        gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
                        docker push ${IMAGE_URL}
                    '''
                }
            }
        }

        stage('Update GitOps Repo') {
            steps {
                // Yahan hum khud deploy nahi kar rahe - ArgoCD isko watch karega aur sync karega.
                // Jenkins ka kaam sirf Git mein naya image tag commit karna hai (GitOps principle).
                sh '''
                    sed -i "s|tag: .*|tag: \\"${BUILD_NUMBER}\\"|" helm/atm-project/values.yaml
                    git config user.email "jenkins-ci@atm-project.local"
                    git config user.name "jenkins-ci"
                    git add helm/atm-project/values.yaml
                    git commit -m "ci: bump image tag to ${BUILD_NUMBER} [skip ci]"
                    git push origin main
                '''
            }
        }
    }

    post {
        success {
            echo "CI completed. Image pushed to Artifact Registry, values.yaml updated - ArgoCD will auto-sync to GKE."
        }
        always {
            sh "docker rmi ${IMAGE_URL} || true"
        }
    }
}
