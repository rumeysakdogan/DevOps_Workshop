# Hands-on Prometheus & Grafana-01: Monitoring Kubernetes

Purpose of the this hands-on training is to give students the knowledge of basic operations for monitoring Kubernetes cluster.

## Learning Outcomes
At the end of this hands-on training, students will be able to;

* Learn deployment of Prometheus to Kubernetes cluster
* Learn how to monitor with Prometheus
* Learn how to create a monitoring dashboard with Grafana

## Outline

- Part 1 - Launching a Kubernetes cluster

- Part 2 - Deploying Prometheus server 

- Part 3 - Monitoring with Prometheus WebUI

- Part 4 - Creating a monitoring dashboard with Grafana 

## Part 1 - Launching a Kubernetes cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](./cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node up and running, worker node automatically joins the cluster.*

- Check if Kubernetes is running.

```bash
$ kubectl cluster-info
```

## Part 2 - Deploying Prometheus server

- Create a dedicated namespace for the Prometheus deployment.

```bash
$ kubectl create namespace prometheus
```

- Create yaml file named **ClusterRole.yml** and explain fields of it.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  - configmaps
  verbs: ["get", "list", "watch"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: default
  namespace: prometheus
```

- Create a ClusterRole and bind this role to prometheus namespace.

```bash
$ kubectl apply -f ClusterRole.yml

clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
```

- Create yaml file named **ConfigMap.yml** to set the scraping and alerting rules for Prometheus and explain the main sections.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
  labels:
    name: prometheus-server-conf
  namespace: prometheus
data:
  rule.yml: |-
    groups:
    - name: Sample Alert
      rules:
      - alert: High Pod Memory
        expr: sum(container_memory_usage_bytes) > 1
        for: 1m
        labels:
          severity: slack
        annotations:
          summary: High Memory Usage
  prometheus.yml: |-
    global:
      scrape_interval: 5s
      evaluation_interval: 5s
    rule_files:
      - /etc/prometheus/rule.yml
    alerting:
      alertmanagers:
      - scheme: http
        static_configs:
        - targets:
          - 'alertmanager.prometheus.svc:9093'

    scrape_configs:
      - job_name: 'kubernetes-apiservers'

        kubernetes_sd_configs:
        - role: endpoints
        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https

      - job_name: 'kubernetes-nodes'

        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        kubernetes_sd_configs:
        - role: node

        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics

      
      - job_name: 'kubernetes-pods'

        kubernetes_sd_configs:
        - role: pod

        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name

      - job_name: 'kubernetes-cadvisor'

        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        kubernetes_sd_configs:
        - role: node

        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      
      - job_name: 'kubernetes-service-endpoints'

        kubernetes_sd_configs:
        - role: endpoints

        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name
```
- Create a Kubernetes configmap that contains scraping and alerting rules for Prometheus.

```bash
$ kubectl apply -f ConfigMap.yml

configmap/prometheus-server-conf created
```

- Create yaml file named **PrometheusDeployment.yml** and explain the fields of it.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-deployment
  namespace: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus-server
  template:
    metadata:
      labels:
        app: prometheus-server
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus/"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config-volume
              mountPath: /etc/prometheus/
            - name: prometheus-storage-volume
              mountPath: /prometheus/
      volumes:
        - name: prometheus-config-volume
          configMap:
            defaultMode: 420
            name: prometheus-server-conf
  
        - name: prometheus-storage-volume
          emptyDir: {}
```

- Deploy Prometheus.

```bash
$ kubectl create -f PrometheusDeployment.yml

deployment.apps/prometheus-deployment created
```

- Validate that Prometheus is running.

```bash
$ kubectl get pods -n prometheus

NAME                                     READY   STATUS    RESTARTS   AGE
prometheus-deployment-78fb5694b4-lmz4r   1/1     Running   0          15s
```

## Part 3 - Monitoring with Prometheus WebUI

- In this section, we'll access the Prometheus UI -The Expression Browser- and review the metrics being collected.

>### Note
>Now Prometheus runs locally. To view the metrics via web browser we need to expose the pod publicly. 

- Create yaml file named **ServiceNodePort.yml** and explain the fields of it.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-prometheus-server
  namespace: prometheus
  labels:
    app: prometheus-server
spec:
  selector:
    app: prometheus-server
  type: NodePort
  ports:
  - name: http
    port: 90
    targetPort: 9090
    protocol: TCP
    nodePort: 32000
```

- Apply ServiceNodePort.yml.

```bash
$ kubectl apply -f ServiceNodePort.yml
```

- Check the assigned port that the metrics will be exposed.

```bash
$ kubectl get svc -n prometheus

NAME                    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web-prometheus-server   NodePort   10.106.87.104   <none>        90:32000/TCP   28s
```

- Edit EC2 Master Node's security group and allow the port that the metrics are exposed (32000 in the above example output) in the inbound rules section.

- Open web browser and go to **http://ec2-54-89-159-197.compute-1.amazonaws.com:32000/**

>### Note
>Replace the address with your EC2 Master Node's public IP address.


## Part 4 - Creating a monitoring dashboard with Grafana

### Install Grafana

- To install the lates OSS release:

```bash
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_9.0.0_amd64.deb
sudo dpkg -i grafana-enterprise_9.0.0_amd64.deb
```

- To start the service:

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl start grafana-server
```

- To verify that the service has started:

```bash
$ sudo systemctl status grafana-server

grafana-server.service - Grafana instance
     Loaded: loaded (/lib/systemd/system/grafana-server.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2020-09-24 08:14:45 UTC; 7s ago
       Docs: http://docs.grafana.org
   Main PID: 39661 (grafana-server)
      Tasks: 8 (limit: 4656)
     Memory: 20.2M
     CGroup: /system.slice/grafana-server.service
             └─39661 /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --pidfile=/var/run/grafana/grafana-s>
```

### Log in for the First Time

- Open your web browser and go to http://localhost:3000 (http://ec2publicip:3000). ```3000``` is the default HTTP port that Grafana listens to if you haven’t configured a different port.

- On the login page, type ```admin``` for the username and password.

- If you want, Change your password. or just ```Skip``` it.

### Add Prometheus as a Data Source

- Move your cursor to the cog on the side menu which will show you the configuration menu. Click on ***Configuration > Data Sources*** in the side menu and you’ll be taken to the data sources page where you can add and edit data sources.

- Click ***Add data source*** and you will come to the settings page of your new data source.

- Select ***Prometheus***

- Write http://localhost:```portnumber``` for URL (Use the same port that is assigned after NodePort.yml is applied). Then click ***Save & Test***.

- Click ***Dashboards*** (next to the Setting).

- Import ***Prometheus 2.0 Stats***

- Click ***Home*** then click ***Prometheus 2.0 Stats***

- Click ***Add new panel***.

### Add CloudWatch as a Data Source

- Move your cursor to the cog on the side menu which will show you the configuration menu. Click on ***Configuration > Data Sources*** in the side menu and you’ll be taken to the data sources page where you can add and edit data sources.

- Click ***Add data source*** and you will come to the settings page of your new data source.

- Select ***CloudWatch***.

- For ***Auth Provider***, Choose ***Access & secret key***.

- Write your ***Access Key ID*** and ***Secret Access Key***.

- Write your ***Default Region***.

- Click ***Save & Test***.

- Click ***Dashboards*** (next to the Setting).

- Import ***Amazon EC2*** and ***Amazon CloudWatch Logs***.

- Click ***Home*** then ***Amazon EC2***.

- Click ***Network Detail*** to see Network traffic.

### Create a New Dashboard

- In the side bar, hover your cursor over the Create (plus sign) icon and then click ***Dashboard***.

- Click ***Add new panel***.

- Click ***Visualization*** (Left Side) and then select ***Gauge***.

- Query Mode : CloudWatch Metrics
- Region : default
- Namespace : AWS/EC2
- Metric Name : CPUUtilization
- Stats : Average
- Dimentions : InstanceId = "Insctance ID"
- Click ***Apply***
