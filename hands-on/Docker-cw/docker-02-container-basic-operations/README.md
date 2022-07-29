# Hands-on Docker-02 : Docker Container Basic Operations

Purpose of the this hands-on training is to give students the knowledge of basic operation on Docker containers.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- list the help about the Docker commands.

- run a Docker container on EC2 instance.

- list the running and stopped Docker containers.

- explain the properties of Docker containers.

- start, stop, and remove Docker containers.

## Outline

- Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Part 2 - Basic Container Commands of Docker

## Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Launch a Docker machine on Amazon Linux 2 AMI with security group allowing SSH connections using the [Cloudformation Template for Docker Machine Installation](../docker-01-installing-on-ec2-linux2/docker-installation-template.yml).

- Connect to your instance with SSH.

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Basic Container Commands of Docker

- Check if the docker service is up and running.

```bash
sudo systemctl status docker
```

- Run either `docker` or `docker help` to see the help docs about docker commands.

```bash
docker help | less
```

- Run `docker COMMAND --help` to see more information about specific command.

```bash
docker run --help | less
```

- Download and run `ubuntu` os with interactive shell open.

```bash
docker run -i -t ubuntu
```

- Display the os name on the container for the current user.

```bash
cat /etc/os-release
```

- Display the shell name on the container for the current user.

```bash
echo $0
```

- Update and upgrade os packages on `ubuntu` container.

```bash
apt-get update && apt-get upgrade -y
```

- Show that `ubuntu` container is like any other Ubuntu system but limited.

  - Go to the home folder and create a file named as `myfile.txt`

    ```bash
    cd ~ && touch myfile.txt && ls
    ```

  - Try to edit `myfile.txt` file with `vim` editor and show that there is no `vim` installed.

    ```bash
    vim myfile.txt
    ```

  - Install `vim` editor.

    ```bash
    apt-get install vim
    ```

  - Edit `myfile.txt` file with `vim` editor and type `Hello from the Ubuntu Container` to show that `vim` command can be run now.

    ```bash
    vim myfile.txt
    ```

- Exit the `ubuntu` container and return to ec2-user bash shell.

```bash
exit
```

- Show the list of all containers available on Docker machine and explain container properties.

```bash
docker ps -a
```

- Run the second `ubuntu` os with interactive shell open and name container as `clarus` and show that this `ubuntu` container is different from the previous one.

```bash
docker run -i -t --name clarus ubuntu
```

- Exit the `ubuntu` container and return to ec2-user bash shell.

```bash
exit
```

- Show the list of all containers again and explain the second `ubuntu` containers' properties and how the names of containers are given.

```bash
docker ps -a
```

- Restart the first container by its `ID`.

```bash
docker start 4e6
```

- Show only running containers and explain the status.

```bash
docker ps
```

- Stop the first container by its `ID` and show it is stopped.

```bash
docker stop 4e6 && docker ps -a
```

- Restart the `clarus` container by its name and list only running containers.

```bash
docker start clarus && docker ps
```

- Connect to the interactive shell of running `clarus` container and `exit` afterwards.

```bash
docker attach clarus
```

- Show that `clarus` container has stopped by listing all containers.

```bash
docker ps -a
```

- Restart the first container by its `ID` again and attach to it to show that the file we have created is still there under the home folder, and exit afterwards.

```bash
docker start 4e6 && docker attach 4e6
```

- Show that we can get more information about `clarus` container by using `docker inspect` command and explain the properties.

```bash
docker inspect clarus | less
```

- Delete the first container using its `ID`.

```bash
docker rm 4e6
```

- Delete the second container using its name.

```bash
docker rm clarus
```

- Show that both of containers are not listed anymore.

```bash
docker ps -a
```
