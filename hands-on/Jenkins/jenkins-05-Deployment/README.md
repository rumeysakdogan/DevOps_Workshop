# Hands-on Jenkins-05 : Deploying Application to Staging/Production Environment with Jenkins

Purpose of the this hands-on training is to learn how to deploy applications to Staging/Production Environment with Jenkins.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- deploy an application to Staging/Production Environment with Jenkins

- automate a Maven project as Pipeline.


## Outline

- Part 1 - Building Web Application

- Part 2 - Deploy Application to Staging Environment

- Part 3 - Update the application and deploy to the staging environment

- Part 4 - Deploy application to production environment

- Part 5 - Automate Existing Maven Project as Pipeline with Jenkins

## Part 1 - Building Web Application

- Fork the `https://github.com/JBCodeWorld/java-tomcat-sample.git` repo.

- Select `New Item`

- Enter name as `build-web-application`

- Select `Free Style Project`

- For Description : `This Job is packaging Java-Tomcat-Sample Project and creates a war file.`

- At `General Tab`, select Discard old builds, `Strategy` is `Log Rotation`, and for `Days to keep builds` enter `5` and `Max # of builds to keep` enter `3`.

- From `Source Code Management` part select `Git`

- Enter `https://github.com/<github-user-name>/java-tomcat-sample.git` for `Repository URL`.

- It is public repo, no need for `Credentials`.

- At `Build Environments` section, select `Delete workspace before build starts` and `Add timestamps to the Console Output` options.

- For `Build`, select `Invoke top-level Maven targets`

  - For `Maven Version`, select the pre-defined maven, `maven-3.8.4` 
  - For `Goals`, write `clean package`
  - POM: `pom.xml`

- At `Post-build Actions` section,
  - Select `Archive the artifacts`
  - For `Files to archive`, write `**/*.war` 

- Finally `Save` the job.

- Click `Build Now` option.

- Observe the Console Output

## Part 2 - Deploy Application to Staging Environment

- Select `New Item`

- Enter name as `Deploy-Application-Staging-Environment`

- Select `Free Style Project`

- For Description : `This Job will deploy a Java-Tomcat-Sample to the staging environment.`

- At `General Tab`, select Discard old builds, `Strategy` is `Log Rotation`, and for `Days to keep builds` enter `5` and `Max # of builds to keep` enter `3`.

- At `Build Environments` section, select `Delete workspace before build starts` and `Add timestamps to the Console Output` options.

- For `Build`, select `Copy artifact from another project`

  - Select `Project name` as `build-web-application`
  - Select `Latest successful build` for `Which build`
  - Check `Stable build only`
  - For `Artifact to copy`, fill in `**/*.war`

- For `Add post-build action`, select `Deploy war/ear to a container`
  - for `WAR/EAR files`, fill in `**/*.war`.
  - for `Context path`, fill in `/`.
  - for `Containers`, select `Tomcat 9.x Remote`.
  - Add credentials
    - Add -> Jenkins
      - Add `username` and `password` as `tomcat/tomcat`.
    - From `Credentials`, select `tomcat/*****`.
  - for `Tomcat URL`, select `private ip` of staging tomcat server like `http://172.31.20.75:8080`.

- Click on `Save`.

- Go to the `Deploy-Application-Staging-Environment` 

- Click `Build Now`.

- Explain the built results.

- Open the staging server url with port # `8080` and check the results.

## Part 3 - Update the application and deploy to the staging environment

-  Go to the `build-web-application`
   -  Select `Configure`
   -  Select the `Post-build Actions` tab
   -  From `Add post-build action`, `Build othe projects`
      -  For `Projects to build`, fill in `Deploy-Application-Staging-Environment`
      -  And select `Trigger only if build is stable` option.
   - Go to the `Build Triggers` tab
     - Select `Poll SCM`
       - In `Schedule`, fill in `* * * * *` (5 stars)
         - You will see the warning `Do you really mean "every minute" when you say "* * * * *"? Perhaps you meant "H * * * *" to poll once per hour`
  
   - `Save` the modified job.

   - At `Project build-web-application`  page, you will see `Downstream Projects` : `Deploy-Application-Staging-Environment`


- Update the web site content, and commit to the GitHub.

- Go to the  `Project build-web-application` and `Deploy-Application-Staging-Environment` pages and observe the auto build & deploy process.

- Explain the built results.

- Open the staging server url with port # `8080` and check the results.

## Part 4 - Deploy application to production environment

- Go to the dashboard

- Select `New Item`

- Enter name as `Deploy-Application-Production-Environment`

- Select `Free Style Project`

- For Description : `This Job will deploy a Java-Tomcat-Sample to the deployment environment.`

- At `General Tab`, select `Strategy` and for `Days to keep builds` enter `5` and `Max # of builds to keep` enter `3`.

- At `Build Environments` section, select `Delete workspace before build starts` and `Add timestamps to the Console Output` and `Color ANSI Console Outputoptions`.

- For `Build`, select `Copy artifact from another project`

  - Select `Project name` as `build-web-application`
  - Select `Latest successful build` for `Which build`
  - Check `Stable build only`
  - For `Artifact to copy`, fill in `**/*.war`

- For `Add post-build action`, select `Deploy war/ear to a container`
  - for `WAR/EAR files`, fill in `**/*.war`.
  - for `Context path`, filll in `/`.
  - for `Containers`, select `Tomcat 9.x Remote`.
  - From `Credentials`, select `tomcat/*****`.
  - for `Tomcat URL`, select `private ip` of production tomcat server like `http://172.31.28.5:8080`.

- Click on `Save`.

- Click `Build Now`.

## Part 5 - Automate Existing Maven Project as Pipeline with Jenkins

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `build-web-application-code-pipeline` then select `Pipeline` and click `OK`.

- Enter `This code pipeline Job is to package the maven project` in the description field.

- At `General Tab`, select `Discard old build`,
  -  select `Strategy` and 
     -  for `Days to keep builds` enter `5` and 
     -  `Max # of builds to keep` enter `3`.

- At `Advanced Project Options: Pipeline` section

  - for definition, select `Pipeline script from SCM`
  - for SCM, select `Git`
    - for `Repository URL`, select `https://github.com/<github-user-name>-tomcat-sample.git`, show the `Jenkinsfile` here.
    - for `Branch Specifier`, enter `*/main` as the GitHub branch is like that.
    - approve that the `Script Path` is `Jenkinsfile`
- `Save` and `Build Now` and observe the behavior.

- Copy the existing 2 jobs ( `Deploy-Application-Staging-Environment` , `Deploy-Application-Production-Environment` ) and modify them for pipeline.

- Go to dashbord click on `New Item` to copy `Deploy-Application-Staging-Environment`

- For name, enter `deploy-application-staging-environment-pipeline`

- At the bottom, `Copy from`, enter `Deploy-Application-Staging-Environment`

- Click `OK`, and `Save`

- Go to dashbord click on `New Item` to copy `Deploy-Application-Production-Environment`

- For name, enter `deploy-application-production-environment-pipeline`

- At the bottom, `Copy from`, enter `Deploy-Application-Production-Environment`

- Click `OK`, and `Save`


- Go to the `deploy-application-staging-environment-pipeline` job

- Find the `Build` section,
  - for `Project name`, enter `build-web-application-code-pipeline` 
  - select `Latest successful build`

- `Save` the job

- Go to the `deploy-application-production-environment-pipeline` job

- Find the `Build` section,
  - for `Project name`, enter `build-web-application-code-pipeline` 
  - select `Latest successful build`

- `Save` the job

- Now, go to the `build-web-application-code-pipeline` job and update the `Jenkinsfile` to include last 2 stages. For this purpose, add these 2 stages in `Jenkinsfile` like below:

```text
        stage('Deploy to Staging Environment'){
            steps{
                build job: 'deploy-application-staging-environment-pipeline'

            }
            
        }
        stage('Deploy to Production Environment'){
            steps{
                timeout(time:5, unit:'DAYS'){
                    input message:'Approve PRODUCTION Deployment?'
                }
                build job: 'deploy-application-production-environment-pipeline'
            }
        }
```

- Note: You can also use updated `Jenkinsfile2` file instead of updating `Jenkinsfile`.

- Go to the `build-web-application-code-pipeline` then select `Build Now` and observe the behaviors.
