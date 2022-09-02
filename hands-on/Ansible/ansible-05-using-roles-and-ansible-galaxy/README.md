# Hands-on Ansible-05 : Using Roles
The purpose of this hands-on training is to give students knowledge of basic Ansible skills.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain what is Ansible role
- Learn how to create, find and use a role.  

## Outline

- Part 1 - Install Ansible

- Part 2 - Using Ansible Roles 

- Part 3 - Using Ansible Roles from Ansible Galaxy



## Part 1 - Install Ansible


- Spin-up 3 Amazon Linux 2 instances and name them as:
    1. control node -->(SSH PORT 22)(Linux)
    2. web_sever_1 ----> (SSH PORT 22, HTTP PORT 80)(Red Hat)
    3. web_server_2 ----> (SSH PORT 22, HTTP PORT 80)(Ubuntu)


- Connect to the control node via SSH and run the following commands.

- Run the commands below to install Python3 and Ansible. 

```bash
$ sudo yum install -y python3 
```

```bash
$ pip3 install --user ansible
```

- Check Ansible's installation with the command below.

```bash
$ ansible --version
```


- Run the command below to transfer your pem key to your Ansible Controller Node.

```bash
scp -i ~/.ssh/walter-pem.pem ~/.ssh/walter-pem.pem ec2-user@54.197.164.241:/home/ec2-user
```


- Make a directory named ```working-with-roles``` under the home directory and cd into it.

```bash 
$ mkdir working-with-roles
$ cd working-with-roles
```

- Create a file named ```inventory.txt``` with the command below.

```bash
$ vi inventory.txt
```

- Paste the content below into the inventory.txt file.

- Along with the hands-on, public or private IPs can be used.

```ini
[servers]
web_server_1   ansible_host=<YOUR-DB-SERVER-IP>   ansible_user=ec2-user  ansible_ssh_private_key_file=~/<YOUR-PEM-FILE>
web_server_2  ansible_host=<YOUR-WEB-SERVER-IP>  ansible_user=ubuntu  ansible_ssh_private_key_file=~/<YOUR-PEM-FILE>

```
- Create file named ```ansible.cfg``` under the the ```working-with-roles``` directory.

```conf
[defaults]
host_key_checking = False
inventory=inventory.txt
interpreter_python=auto_silent
roles_path = /home/ec2-user/ansible/roles/
```


- Create a file named ```ping-playbook.yml``` and paste the content below.

```bash
$ touch ping-playbook.yml
```

```yml
- name: ping them all
  hosts: all
  tasks:
    - name: pinging
      ping:
```

- Run the command below for pinging the servers.

```bash
$ ansible-playbook ping-playbook.yml
```

- Explain the output of the above command.


## Part 2 - Using Ansible Roles

- Install apache server and restart it with using Ansible roles.

```bash
ansible-galaxy init /home/ec2-user/ansible/roles/apache
```
```bash
cd /home/ec2-user/ansible/roles/apache
ll
sudo yum install tree
tree
```

- Create `tasks/main.yml` with the following.

vi tasks/main.yml

```yml
- name: installing apache
  yum:
    name: httpd
    state: latest

- name: index.html
  copy:
    content: "<h1>Hello Clarusway</h1>"
    dest: /var/www/html/index.html

- name: restart apache2
  service:
    name: httpd
    state: restarted
    enabled: yes
```

- Create a playbook named `role1.yml`.
```sh
cd /home/ec2-user/working-with-roles/
vi role1.yml
```
```yml
---
- name: Install and Start apache
  hosts: web_server_1
  become: yes
  roles:
    - apache
```

- Run the command below 

```bash
$ ansible-playbook role1.yml
```

- (if you will use same server, uninstall the apache)

## Part 3 - Using Ansible Roles from Ansible Galaxy

- Go to Ansible Galaxy web site (`www.galaxy.ansible.com`)

- Click the Search option

- Write `nginx`

- Explain the difference beetween collections and roles

- Evaluate the results (stars, number of download, etc.)

- Go to command line and write:

```bash
$ ansible-galaxy search nginx


Stdout:
```
Found 1494 roles matching your search. Showing first 1000.

 Name                                                         Description
 ----                                                         -----------
 0x0i.prometheus                                              Prometheus - a multi-dimensional time-series data mon
 0x5a17ed.ansible_role_netbox                                 Installs and configures NetBox, a DCIM suite, in a pr
 1davidmichael.ansible-role-nginx                             Nginx installation for Linux, FreeBSD and OpenBSD.
 1it.sudo                                                     Ansible role for managing sudoers
 1mr.zabbix_host                                              configure host zabbix settings
 1nfinitum.php                                                PHP installation role.
 2goobers.jellyfin                                            Install Jellyfin on Debian.
 2kloc.trellis-monit                                          Install and configure Monit service in Trellis.
 ```


 - there are lots of. Lets filter them.

```bash
 $ ansible-galaxy search nginx --platform EL
```
"EL" for centos 

- Lets go more specific :

```bash
$ ansible-galaxy search nginx --platform EL | grep geerl

Stdout:

geerlingguy.nginx                                            Nginx installation for Linux, FreeBSD and OpenBSD.
geerlingguy.php                                              PHP for RedHat/CentOS/Fedora/Debian/Ubuntu.
geerlingguy.pimpmylog                                        Pimp my Log installation for Linux
geerlingguy.varnish                                          Varnish for Linux.
```
- Install it:

```bash
$ ansible-galaxy install geerlingguy.nginx

Stdout:

- downloading role 'nginx', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/2.8.0.tar.gz
- extracting geerlingguy.nginx to /home/ec2-user/.ansible/roles/geerlingguy.nginx
- geerlingguy.nginx (2.8.0) was installed successfully
```

- Inspect the role:

```bash
$ cd /home/ec2-user/ansible/roles/geerlingguy.nginx

$ ls
defaults  handlers  LICENSE  meta  molecule  README.md  tasks  templates  vars

$ cd tasks
$ ls

main.yml             setup-Debian.yml   setup-OpenBSD.yml  setup-Ubuntu.yml
setup-Archlinux.yml  setup-FreeBSD.yml  setup-RedHat.yml   vhosts.yml
```
```bash
$ vi main.yml
```
```yml
---
# Variable setup.
- name: Include OS-specific variables.
  include_vars: "{{ ansible_os_family }}.yml"

- name: Define nginx_user.
  set_fact:
    nginx_user: "{{ __nginx_user }}"
  when: nginx_user is not defined

# Setup/install tasks.
- include_tasks: setup-RedHat.yml
  when: ansible_os_family == 'RedHat'

- include_tasks: setup-Ubuntu.yml
  when: ansible_distribution == 'Ubuntu'

- include_tasks: setup-Debian.yml
  when: ansible_os_family == 'Debian'

- include_tasks: setup-FreeBSD.yml
  when: ansible_os_family == 'FreeBSD'

- include_tasks: setup-OpenBSD.yml
  when: ansible_os_family == 'OpenBSD'

- include_tasks: setup-Archlinux.yml
  when: ansible_os_family == 'Archlinux'

# Vhost configuration.
- import_tasks: vhosts.yml

# Nginx setup.
- name: Copy nginx configuration in place.
  template:
    src: "{{ nginx_conf_template }}"
    dest: "{{ nginx_conf_file_path }}"
    owner: root
    group: "{{ root_group }}"
    mode: 0644
  notify:
    - reload nginx
```

- # use it in playbook:

- Create a playbook named `playbook-nginx.yml`

```yml
- name: use galaxy nginx role
  hosts: web_server_2
  become: true

  roles:
    - geerlingguy.nginx
```

- Run the playbook.

```bash
$ ansible-playbook playbook-nginx.yml
```

- List the roles you have:

```bash
$ ansible-galaxy list

Stdout:

- apache, (unknown version)
- geerlingguy.mysql, 3.3.0
```

# Optional

* Assume that we need to create an custom AMI. At this AMI we want to use some software such as docker and prometheus. So in our project, every instance will be created with this AMI. We are also planning to update this AMI every 6 months. So we can update docker and prometheus software versions after 6 months. We need to re-usable configs to do that. Lets talk about this situation.

* First create a new EC2 instance with Ubuntu 20.04 instance image. AMI Number: ami-08d4ac5b634553e16

* We will create yaml to download ansible roles, 

* First install git to Control Node:

```bash
sudo yum install git
```

* Create a file which name is `role_requirements.yml`:

```yml
- src: git+https://github.com/geerlingguy/ansible-role-docker
  name: docker
  version: 2.9.0

- src: git+https://github.com/geerlingguy/ansible-role-ntp
  version: 2.1.0
  name: ansible-role-ntp

- src: git+https://github.com/UnderGreen/ansible-prometheus-node-exporter
  version: master
```

* We will use prometheus at next session to monitor our intances, and NTP is Network Time Protocol. [For more information](https://en.wikipedia.org/wiki/Network_Time_Protocol)

Then run this command:

```bash
ansible-galaxy install -r role_requirements.yml
```

* Check all the roles are created.

* Additionally create a role named with common:

```bash
ansible-galaxy init /home/ec2-user/ansible/roles/common
```

* Then create a playbook file to create instance image.

```yml
---
-
  hosts: instance_image
  become: yes
  become_method: sudo  

  roles:
    - common
    - { role: ansible-role-ntp, ntp_timezone: UTC }
    - docker
    - ansible-prometheus-node-exporter

```

* To apply this, first you need to configure your Inventory file, so add your Ubuntu instance private ip to inventory, give alias name "instance_image".

* When you get ntp error, go and customize common role from ansible/roles/common/tasks/main.yml

```yml
---
# tasks file for /home/ec2-user/ansible/roles/common/tasks/main.yml:
- name: Common Tasks
  debug:
    msg: Common Task Triggered

- name: Fix dpkg
  command: dpkg --configure -a

- name: Update apt
  apt:
    upgrade: dist
    update_cache: yes

- name: Install packages
  apt:
    name: "{{ item }}"
    state: present
  with_items:
    - ntp
```

* Also add a slack notification that shows ansible deployment is finished. 

```yml
---
-
  hosts: instance_image
  become: yes
  become_method: sudo  

  roles:
    - common
    - { role: ansible-role-ntp, ntp_timezone: UTC }
    - docker
    - ansible-prometheus-node-exporter

  tasks:
   - import_tasks: './slack.yml'     
```

./slack.yml is like:

```yml
---
- name: Send slack notification
  slack:
    token: "{{slack_token}}"
    msg: ' {{ inventory_hostname }} Deployed with Ansible'
    # msg: '[{{project_code}}] [{{env_name}}] {{app_name}} {{ inventory_hostname }} {{aws_tags.Name}} '
    channel: "{{slack_channel}}"
    username: "{{slack_username}}"
  delegate_to: localhost
  run_once: true
  become: no
  when: inventory_hostname == ansible_play_hosts_all[-1]
  vars:
    slack_token: "YOUR/TOKEN"
    slack_channel: "#class-chat-tr"
    slack_username: "Ansible"
```

* Then run the playbook command again.
