# Hands-on Kubernetes-03 : Kubernetes Networking and Service Discovery

Purpose of this hands-on training is to give students the knowledge of Kubernetes Services.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Explain the benefits of logically grouping `Pods` with `Services` to access an application.

- Explore the service discovery options available in Kubernetes.

- Learn different types of Services in Kubernetes.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Services, Load Balancing, and Networking in Kubernetes

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](../kubernetes-02-basic-operations/cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have problem with kubernetes cluster, you can use this link for lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Services, Load Balancing, and Networking in Kubernetes

Kubernetes networking addresses four concerns:

- Containers within a Pod use networking to communicate via loopback.

- Cluster networking provides communication between different Pods.

- The Service resource lets you expose an application running in Pods to be reachable from outside your cluster.

- You can also use Services to publish services only for consumption inside your cluster.

### Service

An abstract way to expose an application running on a set of Pods as a network service.

With Kubernetes you don't need to modify your application to use an unfamiliar service discovery mechanism.

Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.

### Motivation

Kubernetes Pods are mortal. They are born and when they die, they are not resurrected. If you use a Deployment to run your app, it can create and destroy Pods dynamically.

Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

### Service Discovery

The basic building block starts with the Pod, which is just a resource that can be created and destroyed on demand. Because a Pod can be moved or rescheduled to another Node, any internal IPs that this Pod is assigned can change over time.

If we were to connect to this Pod to access our application, it would not work on the next re-deployment. To make a Pod reachable to external networks or clusters without relying on any internal IPs, we need another layer of abstraction. K8s offers that abstraction with what we call a `Service Deployment`.

`Services` provide network connectivity to Pods that work uniformly across clusters.
K8s services provide discovery and load balancing. `Service Discovery` is the process of figuring out how to connect to a service.

- Service Discovery is like networking your Containers.

- DNS in Kubernetes is an `Built-in Service` managed by `Kube-DNS`.

- DNS Service is used within PODs to find other services running on the same Cluster.

- Multiple containers running with-in same POD don’t need DNS service, as they can contact each other.

- Containers within same POD can connect to other container using `PORT` on `localhost`.

- To make DNS work POD always need `Service Definition`.

- Kube-DNS is a database containing key-value pairs for lookup.

- Keys are names of services and values are IP addresses on which those services are running.

### Defining and Deploying Services

- Let's define a setup to observe the behaviour of `services` in Kubernetes and how they work in practice.

- Create a folder and name it service-lessons.

```bash
mkdir service-lessons
cd service-lessons
```

- Create `yaml` file named `web-flask.yaml` and explain fields of it.

```yaml
apiVersion: apps/v1 
kind: Deployment 
metadata:
  name: web-flask-deploy
spec:
  replicas: 3 
  selector:  
    matchLabels:
      app: web-flask
  minReadySeconds: 10 
  strategy:
    type: RollingUpdate 
    rollingUpdate:
      maxUnavailable: 1 
      maxSurge: 1 
  template: 
    metadata:
      labels:
        app: web-flask
        env: front-end
    spec:
      containers:
      - name: web-flask-pod
        image: clarusway/cw_web_flask1
        ports:
        - containerPort: 5000
```

- Create the web-flask Deployment.
  
```bash
kubectl apply -f web-flask.yaml
```

- Show the Pods detailed information and learn their IP addresses:

```bash
kubectl get pods -o wide
```

- We get an output like below.

```text
NAME                                READY   STATUS    RESTARTS   AGE   IP               NODE
web-flask-7cbb5f5967-24smj          1/1     Running   0          15m   172.16.166.175   node1
web-flask-7cbb5f5967-94g6f          1/1     Running   0          15m   172.16.166.177   node1
web-flask-7cbb5f5967-gjtkx          1/1     Running   0          15m   172.16.166.176   node1
```

In the output above, for each Pod the IPs are internal and specific to each instance. If we were to redeploy the application, then each time a new IP will be allocated.

We now check we can ping a Pod inside the cluster.

- Create a `forcurl.yaml` file to create a Pod that pings a Pod inside the cluster.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: forcurl
spec:
  containers:
  - name: forcurl
    image: clarusway/forping
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
```

- Create a `forcurl` pod and log into the container.

```bash
kubectl get pods
kubectl apply -f forcurl.yaml
kubectl exec -it forcurl -- sh
/ # ping 172.16.166.180
```

- Show the Pods detailed information and learn their IP addresses again.

```bash
kubectl get pods -o wide
```

- Scale the deployment down to zero.

```bash
kubectl scale deploy web-flask-deploy --replicas=0
```

- List the pods again and note that there is no pod in web-flask-deploy.

```bash
kubectl get pods -o wide
```

- Scale the deployment up to three replicas.

```bash
kubectl scale deploy web-flask-deploy --replicas=3
```

- List the pods again and note that the pods are changed.

```bash
kubectl get pods -o wide
```

- Get the documentation of `Services` and its fields.

```bash
kubectl explain svc
```

- Create a `web-svc.yaml` file with following content and explain fields of it.

```yaml
apiVersion: v1
kind: Service   
metadata:
  name: web-flask-svc
  labels:
    app: web-flask
spec:
  type: ClusterIP  
  ports:
  - port: 3000  
    targetPort: 5000
  selector:
    env: front-end 
```
  
```bash
kubectl apply -f web-svc.yaml
```

- List the services.

```bash
kubectl get svc -o wide
```

```text
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE     SELECTOR
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP                  4h39m   <none>
web-flask-svc   ClusterIP   10.98.173.110   <none>        3000/TCP                 28m     app=web-flask
kube-dns        ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   4h39m   k8s-app=kube-dns
```

- Display information about the `web-flask-svc` Service.

```bash
kubectl describe svc web-flask-svc
```

```text
Name:              web-flask-svc
Namespace:         default
Labels:            app=web-flask
Annotations:       <none>
Selector:          app=web-flask
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4 
IP:                10.105.60.230
IPs:               10.105.60.230
Port:              <unset>  3000/TCP
TargetPort:        5000/TCP
Endpoints:         172.16.180.5:5000,172.16.180.6:5000
Session Affinity:  None
Events:            <none>
```
- Go to the ping pod and ping to the deployment which has service with ClusterIP
```
kubectl exec -it forcurl -- sh
/ # curl <IP of service web-flask-svc>:3000
/ # ping web-flask-svc 
/ # curl web-flask-svc:3000
```

- Create a `clarus-db.yaml` file to create a Pod that connects the web-flask page via curl command.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: clarus-db
spec:
  containers:
  - name: clarus-db
    image: clarusway/clarusdb
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
```

- Create the `clarus-db` pod and log into the container. Connects the web-flask page via curl command and pay attention to load balancig.

```bash
kubectl apply -f clarus-db.yaml
kubectl exec -it clarus-db -- sh
/ # curl <cluster ip of service>:3000   # in our case, cluster ip=10.98.173.110
```

- To connect web-flask page, we can use service name, in our case it is `web-flask-svc`, instead of cluster ip.

```bash
kubectl exec -it clarus-db -- sh
/ # curl web-flask-svc:3000
```

- As we see kubernetes services provide DNS resolution.

### NodePort

- Change the service type of web-flask-svc service to NodePort to use the Node IP and a static port to expose the service outside the cluster. So we get the yaml file below.

```yaml
apiVersion: v1
kind: Service   
metadata:
  name: web-flask-svc
  labels:
    app: web-flask
spec:
  type: NodePort  
  ports:
  - port: 3000  
    targetPort: 5000
  selector:
    env: front-end 
```

- Configure the web-flask-svc service via apply command.

```bash
kubectl apply -f web-svc.yaml
```

- List the services again. Note that kubernetes exposes the service in a random port within the range 30000-32767 using the Node’s primary IP address.

```bash
kubectl get svc -o wide
```

```
kubectl exec -it forcurl -- sh
/ # curl <IP of service web-flask-svc>:3000
/ # ping web-flask-svc 
/ # curl web-flask-svc:3000
```

- We can visit `http://<public-node-ip>:<node-port>` and access the application. Pay attention to load balancing. 
Note: Do not forget to open the Port `<node-port>` in the security group of your node instance.

- We can also define NodePort via adding nodePort number to service yaml file. Check the below. 

```yaml
apiVersion: v1
kind: Service   
metadata:
  name: web-flask-svc
  labels:
    app: web-flask
spec:
  type: NodePort 
  ports:
  - nodePort: 30036  
    port: 3000        
    targetPort: 5000
  selector:
    env: front-end
```

- Configure the web-flask-svc service  again via apply command.

```bash
kubectl apply -f web-svc.yaml
```

- List the services and notice that nodeport number is 30036.

```bash
kubectl get svc -o wide
```

- We can visit `http://<public-node-ip>:30036` and access the application. 

### Endpoints

As Pods come-and-go (scaling up and down, failures, rolling updates etc.), the Service dynamically updates its list of Pods. It does this through a combination of the label selector and a construct called an Endpoint object.

Each Service that is created automatically gets an associated Endpoint object. This Endpoint object is a dynamic list of all of the Pods that match the Service’s label selector.

Kubernetes is constantly evaluating the Service’s label selector against the current list of Pods in the cluster. Any new Pods that match the selector get added to the Endpoint object, and any Pods that disappear get removed. This ensures the Service is kept up-to-date as Pods come and go.

- Get the documentation of `Endpoints` and its fields.

```bash
kubectl explain ep
```

- List the Endpoints.

```bash
kubectl get ep -o wide
```

- Scale the deployment up to ten replicas and list the `Endpoints`.

```bash
kubectl scale deploy web-flask-deploy --replicas=10
```

- List the `Endpoints` and explain that the Service has an associated `Endpoint` object with an always-up-to-date list of Pods matching the label selector.

```bash
kubectl get ep -o wide 
```

> Open a browser on any node and explain the `loadbalancing` via browser. (Pay attention to the host ip and node name and note that `host ips` and `endpoints` are same)
>
> http://[public-node-ip]:[node-port]

### Labels and loose coupling

- Pods and Services are loosely coupled via labels and label selectors. For a Service to match a set of Pods, and therefore provide stable networking and load-balance, it only needs to match some of the Pods labels. However, for a Pod to match a Service, the Pod must match all of the values in the Service’s label selector.

- Add `version: v1` to `web-svc.yaml --> spec.selector`. So that you end up with:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-flask-svc
  labels:
    app: web-flask
spec:
  type: NodePort
  ports:
  - port: 3000
    nodePort: 30036
    targetPort: 5000
  selector:
    env: front-end
    version: v1
```

- Use kubectl apply to push your configuration changes to the cluster.

```bash
kubectl apply -f web-svc.yaml
```

- Reload the page, and see that we can not see the page because of that the Service is selecting on two labels, but the Pods only have one of them. The logic behind this is a Boolean `AND` operation.

- Add `version: v1` to `web-flask.yaml --> spec.template.metadata.labels`. So that you end up with:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-flask-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-flask
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: web-flask
        env: front-end
        version: v1
    spec:
      containers:
      - name: web-flask-pod
        image: clarusway/cw_web_flask1
        ports:
        - containerPort: 5000
```

- Use kubectl apply to push your configuration changes to the cluster.

```bash
kubectl apply -f web-flask.yaml
```

- Reload the page again, and now we can see the page because the `Service` is selecting on two labels and the Pods have all of them.

- Add `test: coupling` to `web-flask.yaml --> spec.template.metadata.labels`. So that you end up with:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-flask-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-flask
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: web-flask
        env: front-end
        version: v1
        test: coupling
    spec:
      containers:
      - name: web-flask-pod
        image: clarusway/cw_web_flask1
        ports:
        - containerPort: 5000
```

- Push your configuration changes to the cluster.

```bash
kubectl apply -f web-flask.yaml
```

- Reload the page again, and we see the page although the `Pods` have additional labels that the `Service` is not selecting on.

### To connect a service from different namespace

- Kubernetes has an add-on for DNS, which creates a DNS record for each Service and its format is:

`web-svc.my-namespace.svc.cluster.local`

- Services within the same Namespace find other Services just by their names. 

- Let's understand this issue with an example.

- First of all remove whole deployment and service into the default namespace

```bash
kubectl delete -f .
```

- Create a namespace and name it `demo`.

```bash
kubectl create namespace demo
```

- Create a deployment inside the `demo` namespace with `web-flask.yaml` file.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-flask-deploy
  namespace: demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-flask
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: web-flask
        env: front-end
        version: v1
        test: coupling
    spec:
      containers:
      - name: web-flask-pod
        image: clarusway/cw_web_flask1
        ports:
        - containerPort: 5000
```
- Create a service inside the `demo` namespace.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-flask-svc
  namespace: demo
  labels:
    app: web-flask
spec:
  type: NodePort
  ports:
  - port: 3000
    targetPort: 5000
    nodePort: 30036
  selector:
    env: front-end
```
- create deployment and service
```bash
kubectl apply -f .
```

- show all namespaces
```bash
kubectl get ns
```

- Lets see the all objects within demo namespace and default namespace
```bash
kubectl get deploy -n demo
kubectl get pod -n demo
kubectl get svc -n demo
kubectl get pod
kubectl get svc
```

- log into the container and curl the `web-flask-svc` inside `demo` namespace.

```bash
kubectl exec -it forcurl -- sh
/ # curl web-flask-svc.demo:3000

or we can use `FQDN`.

/ #  curl web-flask-svc.demo.svc.cluster.local:3000
```

- Delete all objects.

```bash
kubectl delete -f .
kubectl delete ns demo
```