# Hands-on Kubernetes-08: Helm Basics

The purpose of this hands-on training is to give students the knowledge of basic operations of Helm.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Learn basic operations of Helm

- Learn how to create Helm Chart

- Learn how to use AWS S3 as helm repo

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Basic Operations with Helm

- Part 3 - Creating Helm chart

- Part 4 - The Chart Repository

- Part 5 - Set up a Helm v3 chart repository in Github

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](../kubernetes-02-basic-operations/cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node is up and running, the worker node automatically joins the cluster.*

>*Note: If you have a problem with the Kubernetes cluster, you can use this link for the lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get node
```

## Part 2 - Basic Operations with Helm

### [Three Big Concepts](https://helm.sh/docs/intro/using_helm/)

- A `Chart` is a Helm package. It contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster. Think of it like the Kubernetes equivalent of a Homebrew formula, an Apt dpkg, or a Yum RPM file.

- A `Repository` is the place where charts can be collected and shared. It's like Perl's CPAN archive or the Fedora Package Database, but for Kubernetes packages.

- A `Release` is an instance of a chart running in a Kubernetes cluster. One chart can often be installed many times into the same cluster. And each time it is installed, a new release is created. Consider a MySQL chart. If we want two databases running in your cluster, we can install that chart twice. Each one will have its own release, which will in turn have its own release name.

- With these concepts in mind, we can now explain Helm like this:

**Helm installs charts into Kubernetes, creating a new release for each installation. And to find new charts, we can search Helm chart repositories.**

* Install Helm [version 3+](https://github.com/helm/helm/releases) on Jenkins Server. [Introduction to Helm](https://helm.sh/docs/intro/). [Helm Installation](https://helm.sh/docs/intro/install/).

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version
```

### helm search: Finding Charts

- Helm comes with a powerful search command. It can be used to search two different types of sources:

- `helm search hub` searches the Artifact Hub, which lists helm charts from dozens of different repositories.

- `helm search repo` searches the repositories that we have added to your local helm client (with helm repo add). This search is done over local data, and no public network connection is needed.

- We can find publicly available charts by running helm search hub:

```bash
helm search hub
```

- Searches for all wordpress charts on Artifact Hub.

```bash
helm search hub wordpress
```

- We can add the repository using the following command.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

- Using helm search repo, we can find the names of the charts in repositories we have already added:

```bash
helm search repo bitnami
```

- Type the `helm install command` to install a chart.

```bash
helm repo update
helm install mysql-release bitnami/mysql
```

- We get a simple idea of the features of this MySQL chart by running `helm show chart bitnami/mysql`. Or we could run `helm show all bitnami/mysql` to get all information about the chart.

```bash
helm show chart bitnami/mysql
helm show all bitnami/mysql
```

- Whenever we install a chart, a new release is created. So one chart can be installed multiple times into the same cluster. And each can be independently managed and upgraded.

- Install a new release with bitnami/wordpress chart.

```bash
helm install my-release \
  --set wordpressUsername=admin \
  --set wordpressPassword=password \
  --set mariadb.auth.rootPassword=secretpassword \
    bitnami/wordpress
```

- It's easy to see what has been released using Helm.

```bash
helm list
```

- Uninstall a release.

```bash
helm uninstall my-release
helm uninstall mysql-release
```

## Part 3 - Creating Helm chart

- Create a new chart with following command.

```bash
helm create clarus-chart
```

- See the files of clarus-chart.

```bash
ls clarus-chart
```

- Remove the files from `templates` folder.

```bash
rm -rf clarus-chart/templates/*
```

- Create a `configmap.yaml` file under `clarus-chart/templates` folder with following content.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: clarus-chart-config
data:
  myvalue: "Hello World"
```

- Install the clarus-chart.

```bash
helm install helm-demo clarus-chart
```

- The output is similar to:

```bash
NAME: helm-demo
LAST DEPLOYED: Mon Dec  6 11:39:46 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

- List the releases.

```bash
helm ls
```

- Let's see the configmap.

```bash
kubectl get cm
kubectl describe cm clarus-chart-config
```

- Remove the release.

```bash
helm uninstall helm-demo
```

- Let's create our own values and use it within the template. Update the `clarus-chart/values.yaml` as below.

```yaml
course: DevOps
```

- Edit the clarus-chart/templates/configmap.yaml as below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: clarus-chart-config
data:
  myvalue: "clarus-chart configmap example"
  course: {{ .Values.course }}
``` 

- Let's see how the values are getting substituted with the `dry-run` option.

```bash
helm install --debug --dry-run mydryrun clarus-chart
```

- Install the clarus-chart.

```bash
helm install myvalue clarus-chart
```

- Check the values that got deployed with the following command.

```bash
helm get manifest myvalue
```

- Remove the release.

```bash
helm uninstall myvalue
```

- Let's change the default value from the values.yaml file when the release is getting released.

```bash
helm install --debug --dry-run setflag clarus-chart --set course=AWS
```

- We can also get values with built-in objects. Objects can be simple and have just one value. Or they can contain other objects or functions. For example. the Release object contains several objects (like Release.Name) and the Files object has a few functions.

- Edit the clarus-chart/templates/configmap.yaml as below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  myvalue: "clarus-chart configmap example"
  course: {{ .Values.course }}
``` 

- Let's see how the values are getting substituted with the `dry-run` option.

```bash
helm install --debug --dry-run builtin-object clarus-chart
```

- Let's try more examples to get more clarity. Update the `clarus-chart/values.yaml` as below.

```yaml
course: DevOps
lesson:
  topic: helm
```

- So far, we've seen how to place information into a template. But that information is placed into the template unmodified. Sometimes we want to transform the supplied data in a way that makes it more useful to us.

- Helm has over 60 available functions. Some of them are defined by the [Go template language](https://pkg.go.dev/text/template) itself. Most of the others are part of the [Sprig template](https://masterminds.github.io/sprig/) library. Let's see some functions.

- Update the `clarus-chart/templates/configmap.yaml` as below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  myvalue: "clarus-chart configmap example"
  course: {{ quote .Values.course }}
  topic: {{ upper .Values.lesson.topic }}
  time: {{ now | date "2006.01.02" | quote }} 
```

 Let's see how the values are getting substituted with the `dry-run` option.

```bash
helm install --debug --dry-run morevalues clarus-chart
```

- **now** function shows the current date/time.

- **date** function formats a date.

### Helm Notes:

- In this part, we are going to look at Helm's tool for providing instructions to your chart users. At the end of a `helm install` or `helm upgrade`, Helm can print out a block of helpful information for users. This information is highly customizable using templates.

- To add installation notes to your chart, simply create a `clarus-chart/NOTES.txt` file. This file is plain text, but it is processed like a template and has all the normal template functions and objects available.

- Let's create a simple `NOTES.txt` file under `clarus-chart/templates` folder.

```txt
Thank you for installing {{ .Chart.Name }}.

Your release is named {{ .Release.Name }}.

To learn more about the release, try:

  $ helm status {{ .Release.Name }}
  $ helm get all {{ .Release.Name }}
```

- Let's run our helm chart.

```bash
helm install notes-demo clarus-chart
```

- Using NOTES.txt this way is a great way to give your users detailed information about how to use their newly installed chart. Creating a NOTES.txt file is strongly recommended, though it is not required.

- Remove the release.

```bash
helm uninstall notes-demo
```

## Part 4 - The Chart Repository

- In this part, we explain how to create and work with Helm chart repositories. At a high level, a chart repository is a location where packaged charts can be stored and shared. 

- The distributed community Helm chart repository is located at Artifact Hub and welcomes participation. But Helm also makes it possible to create and run your own chart repository. 

- A chart repository is an `HTTP server` that houses an `index.yaml` file and optionally some `packaged charts`. When you're ready to share your charts, the preferred way to do so is by uploading them to a chart repository.

- Because a chart repository can be any HTTP server that can serve YAML and tar files and can answer GET requests, we have a plethora of options when it comes down to hosting your own chart repository. For example, we can use a Google Cloud Storage (GCS) bucket, Amazon S3 bucket, GitHub Pages, or even create your own web server.

### Hosting Chart Repositories

#### ChartMuseum Repository Server

- ChartMuseum is an open-source Helm Chart Repository server written in Go (Golang), with support for cloud storage backends, including Google Cloud Storage, Amazon S3, Microsoft Azure Blob Storage, Alibaba Cloud OSS Storage, Openstack Object Storage, Oracle Cloud Infrastructure Object Storage, Baidu Cloud BOS Storage, Tencent Cloud Object Storage, DigitalOcean Spaces, Minio, and etcd.

- We can also use the ChartMuseum server to host a chart repository from a local file system.

- Install the chartmuseum.

```bash
curl -LO https://s3.amazonaws.com/chartmuseum/release/latest/bin/linux/amd64/chartmuseum
chmod +x ./chartmuseum
sudo mv ./chartmuseum /usr/local/bin
chartmuseum --version
```

- Configure the chartmuseum repo for use with local filesystem storage.

```bash
chartmuseum --debug --port=8080 \
  --storage="local" \
  --storage-local-rootdir="./chartstorage"
```

- Check the repo on your browser. (Don't forget the open port 8080)

```
<public-ip>:8080
```

- Let's add the repository using the following command.

```bash
helm repo add mylocalrepo http://<public-ip>:8080
```

- List the helm repo's.

```bash
helm repo ls
```

- Find the names of the charts in mylocalrepo

```bash
helm search repo mylocalrepo
```

- Let's store charts in your chart repository. Now that we have a chart repository, let's upload a chart and an index file to the repository. Charts in a chart repository must be packaged `helm package chart-name/` and versioned correctly [following SemVer 2 guidelines](https://semver.org/).

```bash
helm package clarus-chart
```

- Once we have a packaged chart ready, create a new directory, and move your packaged chart to that directory.

```bash
mkdir my-charts
mv clarus-chart-0.1.0.tgz my-charts
helm repo index my-charts --url http://<public-ip>:8080
```

- The last command takes the path of the local directory that we just created and the URL of your remote chart repository and composes an `index.yaml` file inside the given directory path.

### The chart repository structure

- A chart repository consists of packaged charts and a special file called index.yaml which contains an index of all of the charts in the repository. Frequently, the charts that index.yaml describes are also hosted on the same server, as are the provenance files.

For example, the layout of the repository https://example.com/charts might look like this:

```
my-charts/
  |
  |- index.yaml
  |
  |- clarus-chart-0.1.0.tgz
```

### The index file

- The index file is a yaml file called `index.yaml`. It contains some metadata about the package, including the contents of a chart's Chart.yaml file. A valid chart repository must have an index file. The index file contains information about each chart in the chart repository. The `helm repo index` command will generate an index file based on a given local directory that contains packaged charts.

This is the index file of my-charts:

```yaml
apiVersion: v1
entries:
  clarus-chart:
  - apiVersion: v2
    appVersion: 1.16.0
    created: "2021-12-07T11:59:09.466396276+03:00"
    description: A Helm chart for Kubernetes
    digest: 712c46edcd85b167881bb644d8de4391eee9acd76aabb75fa2f6e53bedd1c872
    name: clarus-chart
    type: application
    urls:
    - http://<public ip>:8080/clarus-chart-0.1.0.tgz
    version: 0.1.0
generated: "2021-12-07T11:59:09.466104188+03:00"
```

- Now we can upload the chart and the index file to our chart repository using a sync tool or manually.

```bash
cd my-charts
curl --data-binary "@clarus-chart-0.1.0.tgz" http://<public ip>:8080/api/charts
```

- Now we're going to update all the repositories. It's going to connect all the repositories and check is there any new chart.

```bash
helm search repo mylocalrepo
helm repo update
helm search repo mylocalrepo
```

- Let's see how to maintain the chart version. In `clarus-chart/Chart.yaml`, set the `version` value to `0.1.1`and then package the chart.

```bash
helm package clarus-chart
mv clarus-chart-0.1.1.tgz my-charts
helm repo index my-charts --url http://<public-ip>:8080
```

- Upload the new version of the chart and the index file to our chart repository using a sync tool or manually.

```bash
cd my-charts
curl --data-binary "@clarus-chart-0.1.1.tgz" http://<public ip>:8080/api/charts
```

- Let's update all the repositories.

```bash
helm search repo mylocalrepo
helm repo update
helm search repo mylocalrepo
```

- Check all versions of the chart repo with `-l` flag.

```bash
helm search repo mylocalrepo -l
```

- We can also use the [helm-push plugin](https://github.com/chartmuseum/helm-push):

- Install the helm-push plugin. Firstly check the helm plugins.

```
helm plugin ls
helm plugin install https://github.com/chartmuseum/helm-push.git
```

- In clarus-chart/Chart.yaml, set the `version` value to `0.2.0`and push the chart.

```bash
cd
helm cm-push clarus-chart mylocalrepo
```

- Update and search the mylocalrepo.

```bash
helm search repo mylocalrepo
helm repo update
helm search repo mylocalrepo
```

- We can also change the version with the --version flag.

```bash
helm cm-push clarus-chart mylocalrepo --version="1.2.3"
```

- Update and search the mylocalrepo.

```bash
helm search repo mylocalrepo
helm repo update
helm search repo mylocalrepo
```

- Let's install our chart into the Kubernetes cluster.

- Update the `clarus-chart/templates/configmap.yaml` as below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  myvalue: "clarus-chart configmap example"
  course: {{ .Values.course }}
  topic: {{ .Values.lesson.topic }}
  time: {{ now | date "2006.01.02" | quote }} 
  count: "first"
```

- Push the chart again.

```bash
helm cm-push clarus-chart mylocalrepo --version="1.2.4"
```

- Install the chart.

```bash
helm repo update
helm search repo mylocalrepo
helm install from-local-repo mylocalrepo/clarus-chart
```

- Check the configmap.

```bash
kubectl get cm
kubectl describe cm from-local-repo-config
```

- This time we will update the release.

- Update the `clarus-chart/templates/configmap.yaml` as below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  myvalue: "clarus-chart configmap example"
  course: {{ .Values.course }}
  topic: {{ .Values.lesson.topic }}
  time: {{ now | date "2006.01.02" | quote }} 
  count: "second"
```

- Push the chart again.

```bash
helm cm-push clarus-chart mylocalrepo --version="1.2.5"
helm repo update
```

- Update the release.

```bash
helm upgrade from-local-repo mylocalrepo/clarus-chart
```

- Check the configmap.

```bash
kubectl get cm
kubectl describe cm from-local-repo-config
```

- We can check the available versions with `helm history` command.

```bash
helm history from-local-repo
```

- We can upgrade the release to any version with "--version" flag.

```bash
helm upgrade from-local-repo mylocalrepo/clarus-chart --version 1.2.4
```

- Check the configmap.

```bash
kubectl get cm
kubectl describe cm from-local-repo-config
```

- We can rollback our release with `helm rollback` command.

```bash
helm history from-local-repo
helm rollback from-local-repo 1
```

- Check the configmap.

```bash
kubectl get cm
kubectl describe cm from-local-repo-config
```

- Uninstall the release.

```bash
helm uninstall from-local-repo
```

- Remove the localrepo.

```bash
helm repo remove mylocalrepo
```

## Part 5 - Set up a Helm v3 chart repository in Github

- Create a GitHub repo and name it `mygithubrepo`.

- Produce GitHub Apps Personal access tokens. Go to <your avatar> --> Settings --> Developer settings and click Personal access tokens. Make sure to copy your personal access token now. You won’t be able to see it again!

- Create a GitHub repository locally and push it.

```bash
mkdir mygithubrepo
cd mygithubrepo
echo "# mygithubrepo" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/<your github name>/mygithubrepo.git
git push -u origin main
```

- Create a new chart with following command.

```bash
cd ..
helm create demogitrepo
```

- Package the repo under the `mygithubrepo` folder.

```bash
cd mygithubrepo
helm package ../demogitrepo
```

- Generate an index file in the current directory.

```bash
helm repo index .
```

- Commit and push the repo.

```bash
git add .
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git commit -m "demogitrepo chart is added"
git push
```

- Add this repo to your repos. Go to <your repo> --> README.md and click Raw. Copy to address without README.md like below. This will be repo url.

```
https://raw.githubusercontent.com/<github-user-name>/mygithubrepo/main
```

- List the repos and add mygithubrepo.

```bash
helm repo list
helm repo add --username <github-user-name> --password <personel-access-token> my-github-repo 'https://raw.githubusercontent.com/<github-user-name>/mygithubrepo/main'
helm repo list
```

- Let's search the repo.

```bash
helm search repo my-github-repo
```

- Add new charts the repo.

```bash
cd ..
helm create second-chart
cd mygithubrepo
helm package ../second-chart
helm repo index .
git add .
git commit -m "second chart is added"
git push
```

- Update and search the repo.

```bash
helm repo update
helm search repo my-github-repo
```

- Create a release from my-github-repo

```bash
helm install github-repo-release my-github-repo/second-chart
```

- Check the objects.

```bash
kubectl get deployment
kubectl get svc
```

- Uninstall the release.

```bash
helm uninstall github-repo-release
```