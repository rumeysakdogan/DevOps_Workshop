# Hands-on Kubernetes-12 : Kubernetes Pod Scheduling

The purpose of this hands-on training is to give students the knowledge of pod scheduling.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Learn to schedule a pod to a specific node.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Scheduling Pods

- Part 3 - nodeName

- Part 4 - nodeSelector

- Part 5 - Node Affinity  

- Part 6 - Taints and Tolerations

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker). 

>*Note: If you have a problem with the Kubernetes cluster, you can use this link for the lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Scheduling Pods

- In Kubernetes, scheduling refers to making sure that Pods are matched to Nodes so that Kubelet can run them.

- A scheduler watches for newly created Pods that have no Node assigned. For every Pod that the scheduler discovers, the scheduler becomes responsible for finding the best Node for that Pod to run on.

- kube-scheduler is the default scheduler for Kubernetes and runs as part of the control plane.

- For every newly created pod or other unscheduled pods, kube-scheduler selects an optimal node for them to run on. However, every container in pods has different requirements for resources and every pod also has different requirements. Therefore, existing nodes need to be filtered according to the specific scheduling requirements.

- In a cluster, Nodes that meet the scheduling requirements for a Pod are called feasible nodes. If none of the nodes are suitable, the Pod remains unscheduled until the scheduler is able to place it.

- We can constrain a Pod so that it can only run on a particular set of Node(s). There are several ways to do this. Let's start with nodeName.

## Part 3 - nodeName

- For this lesson, we have two instances. The one is the controlplane and the other one is the worker node. As a practice, kube-scheduler doesn't assign a pod to a controlplane. Let's see this.

- Create yaml file named `clarus-deploy.yaml` and explain its fields.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

- Create the deployment with `kubectl apply` command.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that all pods are assigned to the master node.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- For this lesson, we need two worker nodes. Instead of creating an addition node, we will use the controlplane node as both the controlplane and worker node. So, we will arrange a controlplane with the following command.

```bash
kubectl taint nodes kube-master node-role.kubernetes.io/master:NoSchedule-
kubectl taint nodes kube-master node-role.kubernetes.io/control-plane:NoSchedule-
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that pods are assigned to both the master node and worker node.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- `nodeName` is the simplest form of node selection constraint, but due to its limitations, it is typically not used. nodeName is a field of PodSpec. If it is non-empty, the scheduler ignores the pod and the kubelet running on the named node tries to run the pod. Thus, if nodeName is provided in the PodSpec, it takes precedence over the other methods for node selection.

- Some of the limitations of using nodeName to select nodes are:

  - If the named node does not exist, the pod will not be run, and in some cases may be automatically deleted.
  - If the named node does not have the resources to accommodate the pod, the pod will fail and its reason will indicate why, for example, OutOfmemory or OutOfcpu.
  - Node names in cloud environments are not always predictable or stable.

- Let's try this. First list the names of nodes.

```bash
kubectl get no
```

- Update the clarus-deploy.yaml as below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      nodeName: kube-master  #just add this line 
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are assigned to the only worker node.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

## Part 4 - nodeSelector

- `nodeSelector` is the simplest recommended form of node selection constraint. nodeSelector is a field of PodSpec. It specifies a map of key-value pairs. For the pod to be eligible to run on a node, the node must have each of the indicated key-value pairs as labels (it can have additional labels as well). The most common usage is one key-value pair.

- Let's learn how to use nodeSelector.

- First, we will add a label to controlplane node with the following command. 

```bash
kubectl label nodes <node-name> <label-key>=<label-value>
```

- For example, let's assume that we have some applications that require different requirements. And we also have nodes that have different capacities. For this, we want to assign large pods to large nodes. For this, we add a label to controlplane node as below.

```bash
kubectl label nodes kube-master size=large
```

- We can check that the node now has a label with the following command. 

```bash
kubectl get nodes --show-labels
```

- We can also use `kubectl describe node "nodename"` to see the full list of labels of the given node.

- Now, we will update clarus-deploy.yaml as below. We just add `nodeSelector` field.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      nodeSelector:         # This part is added.
        size: large
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are assigned to the only master node.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

## Part 5 - Node Affinity

- `Node affinity`  is conceptually similar to nodeSelector, but it greatly expands the types of constraints we can express. It allows us to constrain which nodes our pod is eligible to be scheduled on, based on labels on the node.

- There are currently three types of node affinity:

  - requiredDuringSchedulingIgnoredDuringExecution
  - preferredDuringSchedulingIgnoredDuringExecution
  - requiredDuringSchedulingRequiredDuringExecution

- Let's analyze this long sentence.

| Types                                           | DuringScheduling | DuringExecution |
| ------------------------------------------------| ---------------- | --------------- |
| requiredDuringSchedulingIgnoredDuringExecution  | required         | Ignored         |
| preferredDuringSchedulingIgnoredDuringExecution | preferred        | Ignored         |
| requiredDuringSchedulingRequiredDuringExecution | required         | required        |


- The first one (requiredDuringSchedulingIgnoredDuringExecution) specifies rules that must be met for a pod to be scheduled onto a node (similar to nodeSelector but using a more expressive syntax), while the second one (preferredDuringSchedulingIgnoredDuringExecution) specifies preferences that the scheduler will try to enforce but will not guarantee. For example, we specify labels for nodes and nodeSelectors for pods.
Later, the labels of the node are changed. If we use the first one (requiredDuringSchedulingIgnoredDuringExecution), the pod is not be scheduled. Let's see this.

- We will update clarus-deploy.yaml as below. We will add an affinity field instead of nodeSelector.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: size
                operator: In
                values:
                - large
                - medium
```

- This node affinity rule says the pod can only be placed on a node with a label whose key is size and whose value is large or medium.

- We have already labeled the controlplane node with `size=large` key-value pair. Let's see.

```bash
kubectl get nodes --show-labels
```

- Create the clarus-deploy.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are running on the controlplane.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- Edit the controlplane node and delete `size=large` line from `labels` field.

```bash
kubectl edit node  kube-master
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are pending state. Because there is no node labeled with size=large.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- This time we will test `preferredDuringSchedulingIgnoredDuringExecution`. Update clarus-deploy.yaml as below. This time, we change `requiredDuringSchedulingIgnoredDuringExecution` with  `preferredDuringSchedulingIgnoredDuringExecution`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:   # This field is changed.
          - weight: 1                                        # This field is changed.         
            preference:                                      # This field is changed.   
              matchExpressions:
              - key: size
                operator: In
                values:
                - large
                - medium
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are running on both the master node and worker node. Because this time it specifies preferences that the scheduler will try to enforce but will not guarantee. If there is no node labeled, the scheduler will assign randomly.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- The `IgnoredDuringExecution` part of the names means that similar to how nodeSelector works, if labels on a node change at runtime such that the affinity rules on a pod are no longer met, the pod continues to run on the node. In the future, the Kubernetes community plans to offer `requiredDuringSchedulingRequiredDuringExecution` which will be identical to `requiredDuringSchedulingIgnoredDuringExecution` except that it will evict pods from nodes that cease to satisfy the pods' node affinity requirements.


## Part 6 - Taints and Tolerations

- Taints allow a node to repel a set of pods.

- Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints.

- Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints.

- First of all, we will see that there is no taint in any node.

```bash
kubectl get no
kubectl describe node kube-master | grep -i taint
kubectl describe node kube-worker-1 | grep -i taint
```

- As we see, there is no taint for our nodes.

- We can add taint in the format below.

```bash
kubectl taint nodes node-name key=value:taint-effect
```

- Let's add a taint to the kube-worker-1 using `kubectl taint` command.

```bash
kubectl taint nodes kube-worker-1 clarus=way:NoSchedule
```

- This command places a taint on node kube-worker-1. The taint has key clarus, value way, and taint effect NoSchedule. This means that no pod will be able to schedule onto kube-worker-1 unless it has matching toleration.

- Check that there is a taint for kube-worker-1.

```bash
kubectl describe node kube-worker-1 | grep -i taint
```

- Update the clarus-deploy.yaml as below. 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

- Create the clarus-deploy again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are assigned to the only master node.

```bash
kubectl get po -o wide
```

- We specify toleration for a pod in the PodSpec. Both of the following tolerations "match" the taint created by the kubectl taint line above, and thus a pod with either toleration would be able to schedule onto kube-worker-1:

```yaml
tolerations:
- key: "clarus"
  operator: "Equal"
  value: "way"
  effect: "NoSchedule"
```

or

```yaml
tolerations:
- key: "clarus"
  operator: "Exists"
  effect: "NoSchedule"
```

- Update the clarus-deploy.yaml as below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 15
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      tolerations:
      - key: "clarus"
        operator: "Exists"
        effect: "NoSchedule"
```

- List the pods.

```bash
kubectl get po -o wide
```

- Run the deployment again.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that the pods are running at both master node and worker node.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml
```

> Taints and tolerations are not used to assign a pod to a node, they only restrict nodes from accepting certain tolerations.
> If we want to assign a pod to a specific node, we will use the other concept, Node Affinity.

- Remove taint from the kube-worker-1 node.

```bash
kubectl taint nodes kube-worker-1 clarus=way:NoSchedule-
```



