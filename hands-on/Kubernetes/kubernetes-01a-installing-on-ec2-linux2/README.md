# Hands-on Kubernetes-01a : Installing Kubernetes on Ubuntu 20.04 running on AWS EC2 Instances

Purpose of the this hands-on training is to give students the knowledge of how to install and configure Kubernetes on Ubuntu 20.04 EC2 Instances.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- install Kubernetes on Ubuntu 20.04.

- explain steps of the Kubernetes installation.

- set up a Kubernetes cluster.

- explain the Kubernetes architecture.

- deploy a simple server on Kubernetes cluster.

## Outline

- Part 1 - Setting Up Kubernetes Environment on All Nodes

- Part 2 - Setting Up Master Node for Kubernetes

- Part 3 - Adding the Slave/Worker Nodes to the Cluster

- Part 4 - Deploying a Simple Nginx Server on Kubernetes


## Part 1 - Setting Up Kubernetes Environment on All Nodes

- In this hands-on, we will prepare two nodes for Kubernetes on `Ubuntu 20.04`. One of the node will be configured as the Master node, the other will be the worker node. Following steps should be executed on all nodes. *Note: It is recommended to install Kubernetes on machines with `2 CPU Core` and `2GB RAM` at minimum to get it working efficiently. For this reason, we will select `t2.medium` as EC2 instance type, which has `2 CPU Core` and `4 GB RAM`.*

- Explain briefly [required ports](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)  for Kubernetes. 

- Create two security groups. Name the first security group as master-sec-group and apply the following Control-plane (Master) Node(s) table to your master node.

- Name the second security group as worker-sec-group, and apply the following Worker Node(s) table to your worker nodes.

### Control-plane (Master) Node(s)

|Protocol|Direction|Port Range|Purpose|Used By|
|---|---|---|---|---|
|TCP|Inbound|6443|Kubernetes API server|All|
|TCP|Inbound|2379-2380|`etcd` server client API|kube-apiserver, etcd|
|TCP|Inbound|10250|Kubelet API|Self, Control plane|
|TCP|Inbound|10259|kube-scheduler|Self|
|TCP|Inbound|10257|kube-controller-manager|Self|
|TCP|Inbound|22|remote access with ssh|Self|
|UDP|Inbound|8472|Cluster-Wide Network Comm. - Flannel VXLAN|Self|

### Worker Node(s)

|Protocol|Direction|Port Range|Purpose|Used By|
|---|---|---|---|---|
|TCP|Inbound|10250|Kubelet API|Self, Control plane|
|TCP|Inbound|30000-32767|NodePort Services†|All|
|TCP|Inbound|22|remote access with ssh|Self|
|UDP|Inbound|8472|Cluster-Wide Network Comm. - Flannel VXLAN|Self|

> **Ignore this section for AWS instances. But, it must be applied for real servers/workstations.**
>
> - Find the line in `/etc/fstab` referring to swap, and comment out it as following.
>
> ```bash
> # Swap a usb extern (3.7 GB):
> #/dev/sdb1 none swap sw 0 0
>```
>
> or,
>
> - Disable swap from command line
>
> ```bash
> free -m
> sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab
> ```
>

- Hostname change of the nodes, so we can discern the roles of each nodes. For example, you can name the nodes (instances) like `kube-master, kube-worker-1`

```bash
sudo hostnamectl set-hostname <node-name-master-or-worker>
bash
```

- Install helper packages for Kubernetes.

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
```

- Update app repository and install Kubernetes packages and Docker.

```bash
sudo apt-get update

sudo apt-get install -y kubectl kubeadm kubelet kubernetes-cni docker.io
```

- Start and enable Docker service.

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

- Add the current user to the `Docker group`, so that the `Docker commands` can be run without `sudo`.

```bash
sudo usermod -aG docker $USER
newgrp docker
```

- As a requirement, update the `iptables` of Linux Nodes to enable them to see bridged traffic correctly. Thus, you should ensure `net.bridge.bridge-nf-call-iptables` is set to `1` in your `sysctl` config and activate `iptables` immediately.

```bash
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

## Part 2 - Setting Up Master Node for Kubernetes

- Following commands should be executed on Master Node only.

- Pull the packages for Kubernetes beforehand

```bash
sudo kubeadm config images pull
```

- By default, the Kubernetes cgroup driver is set to system, but docker is set to systemd. We need to change the Docker cgroup driver by creating a configuration file `/etc/docker/daemon.json` and adding the following line then restart deamon, docker and kubelet:

```bash
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet
```

- Let `kubeadm` prepare the environment for you. Note: Do not forget to change `<ec2-private-ip>` with your master node private IP.

```bash
sudo kubeadm init --apiserver-advertise-address=<ec2-private-ip> --pod-network-cidr=10.244.0.0/16
```

> :warning: **Note**: If you are working on `t2.micro` or `t2.small` instances,  use the command with `--ignore-preflight-errors=NumCPU` as shown below to ignore the errors.

>```bash
>sudo kubeadm init --apiserver-advertise-address=<ec2 private ip> --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU
>```

> **Note**: There are a bunch of pod network providers and some of them use pre-defined `--pod-network-cidr` block. Check the documentation at the References part. We will use Flannel for pod network and Flannel uses 10.244.0.0/16 CIDR block. 

- In case of problems, use following command to reset the initialization and restart from Part 2 (Setting Up Master Node for Kubernetes).

```bash
sudo kubeadm reset
```

- After successful initialization, you should see something similar to the following output (shortened version).

```bash
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

  kubeadm join 172.31.3.109:6443 --token 1aiej0.kf0t4on7c7bm2hpa \
      --discovery-token-ca-cert-hash sha256:0e2abfb56733665c0e6204217fef34be2a4f3c4b8d1ea44dff85666ddf722c02
```

> Note to the Instructor: Note down the `kubeadm join ...` part in order to connect your worker nodes to the master node. Remember to run this command with `sudo`.

- Run following commands to set up local `kubeconfig` on master node.

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Activate the `Flannel` pod networking and explain briefly the about network add-ons on `https://kubernetes.io/docs/concepts/cluster-administration/addons/`.

```bash
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
```

- Master node (also named as Control Plane) should be ready, show existing pods created by user. Since we haven't created any pods, list should be empty.

```bash
kubectl get nodes
```

- Show the list of the pods created for Kubernetes service itself. Note that pods of Kubernetes service are running on the master node.

```bash
kubectl get pods -n kube-system
```

- Show the details of pods in `kube-system` namespace. Note that pods of Kubernetes service are running on the master node.

```bash
kubectl get pods -n kube-system -o wide
```

- Get the services available. Since we haven't created any services yet, we should see only Kubernetes service.

```bash
kubectl get services
```

- Show the list of the Docker images running on the Master node to enable Kubernetes service.

```bash
docker container ls
```

## Part 3 - Adding the Slave/Worker Nodes to the Cluster

- Show the list of nodes. Since we haven't added worker nodes to the cluster, we should see only master node itself on the list.

```bash
kubectl get nodes
```

- Run `docker container ls` on the worker nodes command to list the Docker images running on the worker nodes. We should see an empty list.

- By default, the Kubernetes cgroup driver is set to system, but docker is set to systemd. We need to change the Docker cgroup driver by creating a configuration file `/etc/docker/daemon.json` and adding the following line then restart deamon, docker and kubelet:

```bash
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet
```

- Run `sudo kubeadm join...` command to have them join the cluster.

```bash
sudo kubeadm join 172.31.3.109:6443 --token 1aiej0.kf0t4on7c7bm2hpa \
    --discovery-token-ca-cert-hash sha256:0e2abfb56733665c0e6204217fef34be2a4f3c4b8d1ea44dff85666ddf722c02
```

- Go to the master node. Get the list of nodes. Now, we should see the new worker nodes in the list.

```bash
kubectl get nodes
```

- Get the details of the nodes.

```bash
kubectl get nodes -o wide
```

## Part 4 - Deploying a Simple Nginx Server on Kubernetes

- Check the readiness of nodes at the cluster on master node.

```bash
kubectl get nodes
```

- Show the list of existing pods in default namespace on master. Since we haven't created any pods, list should be empty.

```bash
kubectl get pods
```

- Get the details of pods in all namespaces on master. Note that pods of Kubernetes service are running on the master node and also additional pods are running on the worker nodes to provide communication and management for Kubernetes service.

```bash
kubectl get pods -o wide --all-namespaces
```

- Create and run a simple `Nginx` Server image.

```bash
kubectl run nginx-server --image=nginx  --port=80
```

- Get the list of pods in default namespace on master and check the status and readyness of `nginx-server`

```bash
kubectl get pods -o wide
```

- Expose the nginx-server pod as a new Kubernetes service on master.

```bash
kubectl expose pod nginx-server --port=80 --type=NodePort
```

- Get the list of services and show the newly created service of `nginx-server`

```bash
kubectl get service -o wide
```

- You will get an output like this.

```text
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        13m    <none>
nginx-server   NodePort    10.110.144.60   <none>        80:32276/TCP   113s   run=nginx-server
```

- Open a browser and check the `public ip:<NodePort>` of worker node to see Nginx Server is running. In this example, NodePort is 32276.

- Clean the service and pod from the cluster.

```bash
kubectl delete service nginx-server
kubectl delete pods nginx-server
```

- Check there is no pod left in default namespace.

```bash
kubectl get pods
```

- To delete a worker/slave node from the cluster, follow the below steps.

  - Drain and delete worker node on the master.

  ```bash
  kubectl get nodes
  kubectl cordon kube-worker-1
  kubectl drain kube-worker-1 --ignore-daemonsets --delete-emptydir-data

  kubectl delete node kube-worker-1
  ```

  - Remove and reset settings on the worker node.

  ```bash
  sudo kubeadm reset
  ```
  
> Note: If you try to have worker rejoin cluster, it might be necessary to clean `kubelet.conf` and `ca.crt` files and free the port `10250`, before rejoining.
>
> ```bash
>  sudo rm /etc/kubernetes/kubelet.conf
>  sudo rm /etc/kubernetes/pki/ca.crt
>  sudo netstat -lnp | grep 10250
>  sudo kill <process-id>
>  ```


# References

- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

- https://kubernetes.io/docs/concepts/cluster-administration/addons/

- https://kubernetes.io/docs/reference/

- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-strong-getting-started-strong-
