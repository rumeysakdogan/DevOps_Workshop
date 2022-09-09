# Hands-on 01: Create Nexus Proxy and Hosted Repositories for a Maven Project

Purpose of this hands-on training is to learn how to create and use Nexus repositories to store a Maven project.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Create hosted and proxy repostiories.

- Create a group repository consisting of hosted and proxy repositories.

- Consolidate all the components of a project into a repository group.

## Outline

- Part 1 - Start Nexus Repository and Create Credentials

- Part 2 - Create and Build a Maven Project (POM)

- Part 3 - Create Maven Proxy Repository

- Part 4 - Create New Components from Maven Central to the Proxy

- Part 5 - Configure and Build Components in Maven Hosted Repository

- Part 6 - Create a Maven Group Repository Consisting of Previously Created Hosted and Proxy Repositories

- Part 7 - Check the Components in the Group Repository by Accesing the UI

## Part 1 : Start Nexus Repository and Create Credentials

- Launch an t2.medium (Nexus needs 8 GB of RAM) EC2 instance using the Amazon Linux 2 AMI with security group allowing `SSH (22)` and `Nexus Port (8081)` connections.

- Connect to your instance with SSH:

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

- Update the OS:

```
sudo yum update -y
```


- Install Java:
Maven is Java based application, so to run Maven we have to install Java on the server.

```
sudo yum install java-1.8.0-openjdk -y
java -version
```

- Download and install Maven:

```
sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo

ls /etc/yum.repos.d/
```

```
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
```

```
sudo yum install apache-maven -y
mvn -version
whereis mvn
```

- Download and install Nexus.

```
cd /opt
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
ls
```

```
sudo tar xvzf nexus.tar.gz
ls
sudo rm nexus.tar.gz
ls
```

Rename  nexus-3* directory for convenience:
```
sudo mv nexus-3* nexus
ls
```

- Give the ownership of the directories related to Nexus to the ec2-user:

```
ll
sudo chown -R ec2-user:ec2-user /opt/nexus
sudo chown -R ec2-user:ec2-user /opt/sonatype-work
ll
```

- Tell nexus that ec2-user is going to be running the service. Edit the nexus.rc file with this `run_as_user="ec2-user"` content:

```
nano /opt/nexus/bin/nexus.rc
```

```
cd /opt/nexus/bin
ls
```

- Add the path of nexus binary to the PATH variable and run nexus.

```
export PATH=$PATH:/opt/nexus/bin
echo $PATH
nexus start
```

- Another way to run nexus as a service.

Run Nexus as Systemctl Service:

- First, we have to add Nexus service to systemctl. Create a new file named `nexus.service` in the following directory:

```
sudo nano /etc/systemd/system/nexus.service
```

- Add this content to the nexus.service file:

```
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=ec2-user
Group=ec2-user
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=ec2-user
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

Finally, enable nexus and start the service: 
```
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service
sudo systemctl status nexus.service
```

- Open your browser to load the repository manager: `http://<AWS public dns>:8081`

- To Retrieve the temporary password from `admin.password` file.

```
more /opt/sonatype-work/nexus3/admin.password
```

- Open Nexus service from the browser and click `Sing in` upper right of the page. A box will pop up.
Write `admin` for Username and paste the string which you copied from admin.password file for the password.

- Click the Sign in button to start the Setup wizard. Click Next through the steps to update your password.

- Leave the Enable Anonymous Access box unchecked.

- Click Finish to complete the wizard.

## Part 2 : Create and Build a Maven Project (POM)

- Use your terminal to create a sample POM.

- Create a project folder, name it `nexus-hands-on` and change that directory.

```
cd
mkdir nexus-hands-on && cd nexus-hands-on
```

- Create a pom.xml in the nexus-hands-on directory: 

```
nano pom.xml
```

- Open the POM file with a text editor in your terminal and add the following snippet.

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>nexus-proxy</artifactId>
  <version>1.0-SNAPSHOT</version>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.10</version>
    </dependency>
  </dependencies>
</project>
```

## Part 3 : Create Maven Proxy Repository

- Open Nexus Repository Manager UI

- Create a repo called `maven-proxy-hands-on`.

- Click the setting button after that `Repositories`. Then click `Create repository` and choose recipe: `maven2 (proxy)`.

- Name: `maven-proxy-hands-on`

- Remote storage URL:  `https://repo1.maven.org/maven2`

- Click Create repository to complete the form.

- Nexus searchs for settings.xml in the `/home/ec2-user/.m2` directory. .m2 directory is created after running the first mvn command.

```
mvn
curl http://169.254.169.254/latest/meta-data/public-ipv4
nano /home/ec2-user/.m2/settings.xml
```
52.90.127.112
- Your settings.xml file should look like this (Don't forget to change the URL of your repository and the password): 3.89.163.211

```
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS:8081/repository/maven-proxy-hands-on/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

## Part 4 : Create New Components from Maven Central to the Proxy

- Run the build with the command `mvn package`. Your build is ready when you see a BUILD SUCCESS message.

```
pwd && ls
mvn package
ls
cd target && ls
```

- Click Browse button in the main toolbar of Nexus to see the list of repositories.

- Click `Browse` from the left-side menu.

- Click `maven-proxy-hands-on`. You’ll see the components you built in the previous exercise.

- Click on the component name to review its details.

## Part 5 : Configure and Build Components in Maven Hosted Repository

- Next up, configure Maven release and snapshot repositories (which come configured with the nexus repository manager) for deployment. This means that we will just update the pom.xml and settings.xml. We will not create repositories.

- Your mirror URL now should point to http://<AWS public DNS>:8081/repository/maven-public 

- Open your settings.xml and change the URL of your repository `maven-proxy-hands-on` to `maven-public`.

```
nano /home/ec2-user/.m2/settings.xml
```

```
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS>:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

- Add distributionManagement element given below to your pom.xml file after `</dependencies>` line. Include the endpoints to your maven-releases and maven-snapshots repos. Change localhost >>>> Public ip of your server.

```
curl http://169.254.169.254/latest/meta-data/public-ipv4
nano /home/ec2-user/nexus-hands-on/pom.xml
```

```
  <distributionManagement>
    <repository>
      <id>nexus</id>
      <name>maven-releases</name>
      <url>http://localhost:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
      <id>nexus</id>
      <name>maven-snapshots</name>
      <url>http://localhost:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
```

``` 
cd /home/ec2-user/nexus-hands-on
mvn clean deploy
cd target && ls
```

- Once you see BUILD SUCCESS, you can see the components in the repository from the UI. Check the components inside the snapshot and public repository. 

- Open the POM and remove the -SNAPSHOT tag from the version element.

```
nano /home/ec2-user/nexus-hands-on/pom.xml
```

Run the releases build: 

```
mvn clean deploy
```

- Once you see `BUILD SUCCESS`, you can see the components in the repository from the UI. Go and check the components in the release and public repository.

## Part 6 : Create a Maven Group Repository Consisting of Previously Created Hosted and Proxy Repositories

- Create the repository group – the centralized endpoint to access hosted and proxied components. Remember to order the repositories as hosted, then proxy. Do the following to create the repository:

- Open Nexus Repository Manager UI

- Create a repo called `maven-all`.

- Click the setting button after that `Repositories`. Then click `Create repository` and choose recipe: `maven2 (group)`.

- Name: `maven-all`

- Drag and drop the Available repositories you created in the earlier exercises to the Members field.

- Click Create repository to complete the form.

- Copy the URL from the Group Repository you just created. (In this exercise, the repository URL is http://<AWS public DNS>:8081/repository/maven-all).

- Modify the mirror configuration in your settings.xml to point to your group. So the "<url>" tag should have `http://<AWS public DNS>:8081/repository/maven-all` inside it.

```
nano /home/ec2-user/.m2/settings.xml
```

- So your settings.xml should look like this: 

```
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS>:8081/repository/maven-all/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

- Download components directly to your repository group.

```
cd /home/ec2-user/nexus-hands-on
mvn install
```

## Part 7 : Check the Components in the local repository that was installed from the Group Repository that was configured

- Go inside the .m2/repository/ 

```
cd /home/ec2-user/.m2/repository && ls
```

- You will see that you have everything installed that is on your group repository. 



