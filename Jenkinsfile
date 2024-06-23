// SPDX-FileCopyrightText: Copyright contributors to the Software Quality Assurance as a Service (SQAaaS) project <sqaaas@ibergrid.eu>
// SPDX-FileContributor: Pablo Orviz <orviz@ifca.unican.es>
//
// SPDX-License-Identifier: GPL-3.0-only

@Library(['github.com/indigo-dc/jenkins-pipeline-library@2.1.1']) _

def projectConfig

pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                git branch: 'main', url: 'https://github.com/mattiaBarbo/SQAaaS_Test.git'
                sh 'python3 test_main.py'
            }
        }
        stage('Test') {
            steps {
                sh 'python3 -m pytest -v'
            }
        }
        stage('SQA baseline criterion: QC.Doc & QC.Sty') {
            steps {
                script {
                    projectConfig = pipelineConfig(
                        configFile: '.sqa/config.yml',
                        scmConfigs: [ localBranch: true ],
                        validatorDockerImage: 'eoscsynergy/jpl-validator:2.4.0'
                    )
                    buildStages(projectConfig)
                }
            }
            post {
                cleanup {
                    cleanWs()
                }
            }
        }
    }
}