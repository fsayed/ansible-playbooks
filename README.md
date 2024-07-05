# Ansible Playbooks

* Create one or more VMs
* Register DNS records with BlueCat
* Configure one or more VMs

## Requirement

    Ansible 2.6 or higher

    python-netaddr module

    python3 and pyvmomi module for deploying a VM with Ansible

## Setup

```bash
    yum/apt-get/pip install ansible
```

## Configure

Since we are using ansible-vault, there are couple ways we can set this up but here how I(Parinya) configured it:

1) Create an ansible-vault password in a file ~/.vault_pass

This file just contains one line (password) nothing else and make sure
to secure it on your local workstation that you are running
ansible-playbook from. (chmod 0400 ...)

Note that the ansible-vault password is in the syseng password file.

2) Create/Modify your ~/.ansible.cfg

and add under [defaults] section ...

```
    [defaults]
    ..
    ..
    ..

    vault_password_file = ~/.vault_pass
```


That's it. Next time when you run ansible, ansible knows what password to use to decrypt the ansible-vault contents.


3) Setup shell environment variables


For example: I create a file ~/.ansible-env with the following content:

```bash
    export VMWARE_USER='fahad@afilias.info'
    export VMWARE_PASSWORD='My Password for VMware'
    export BLUECAT_USER='bluecat-api-user'
    export BLUECAT_PASSWORD='bluecat-api-user-password'
```


**NOTE:**

* Make sure YOU are the only one can access this file. So, this means it's your private laptop/workstation/VM.
* We have a dedicated user for BlueCat access. You could use your credential for this but you will need to enable API access for your user in BlueCat.


## Deploy and Configure one or more VMs


In order to deploy and configure VM(s), the steps following need to be done:

1) Prepare each VM specs as an Ansible hostvar file( We will be using the hostvar file(s) to provision and configure the VM(s) )

For this example, I am going to create 7 VMs names **fahad-test1/2/3/4/5/6/7** in **Toronto VMware environment**:

First, I create Ansible hostvar files under **ansible-playbooks/tor/host_vars/** for each VM. 

For example: **ansible-playbooks/tor/host_vars/fahad-test6.tor.afilias-int.info** for **fahad-test6** VM.


```yaml
    ---

    vm_name: fahad-test6

    num_cpus: 1
    num_cpu_cores_per_socket: 1
    memory_mb: 2048
    cluster: Cluster 1
    folder: Lab/Parinya
    template: centos-7-x86_64-template

    disk:
        - size_gb: 32
          type: thin
          datastore: silverstore2
        - size_gb: 10
          type: thin
          datastore: silverstore3

    interfaces:
        - id: 0
          name: Operations
          bootproto: none
          onboot: yes
          ip: 10.10.24.216
          prefix: 21
          dns_name: fahad-test6.tor.afilias-int.info
          dns_alias: fahad-6.tor.afilias-int.info
          ipv6: yes
          gateway: 10.10.24.1

        - id: 1
          name: VMware Management Network
          bootproto: none
          onboot: yes
          ipv6: yes
```



As you may be able to guess, fahad-test6 VM will have the following specs after create:

* 1 CPU
* 2G of memory
* Put the VM under Lab/Parinya folder
* There will be two thin provisioning disks, one for OS(from silverstore2) and another 10G disk(from silverstore3)
* There are 2 network interfaces. The first interface will be in **Operations** portgroup, and the 2nd will be in **VMware Management Network** portgroup
* 3 DNS records will be created. (1xA record, 1xCNAME record and 1xPTR record)


    A record: fahad-test6.tor.afilias-int.info. is pointing to 10.10.24.216 IP
    
    CNAME record: fahad-6.tor.afilias-int.info. will be pointing to fahad-test6.tor.afilias-int.info.

    PTR record: 10.10.24.216.in-addr.arpa. will be pointing to fahad-test6.tor.afilias-int.info.

    
I then create the rest hostvar files (for fahad-test1/2/3/4/5 and fahad-test7)


**NOTE:**

* As you can see the VM hostvar is very similar to what we have been using with some more info added to describe the VM.
* Here is the difference: You must not have **type** under **interfaces** variable. Usually this line will be **type: Ethernet** . So, if you copy from your old definition, please remove it. It will conflict with Ansible vmware_guest role that we will be using.
* You do not need to include all the variables in the hostvar, they will use their default values if you don't include them. For example:

```
    cluster - default depending on which datacenter

    template - default depending on which datacenter
    folder - /
    num_cpus - 1 
    num_cpu_cores_per_socket - 1
    ...
    ...
```


2) After we prepare hostvar files for **every VMs** we would like to create, we will need to add the VMs into Ansible inventory file. This depends on datacenter where the VM(s) will be. 


3) We will need to prepare a YML file containing a list of VM FQDN. In my case, I'm creating 7 VMs fahad-test1/2/3/4/5/6/7 in Toronto vSphere so I create **new-hosts.yml** file with the following content:

```yaml
    ---
    hostnames:
        - fahad-test1.tor.afilias-int.info
        - fahad-test2.tor.afilias-int.info
        - fahad-test3.tor.afilias-int.info
        - fahad-test4.tor.afilias-int.info
        - fahad-test5.tor.afilias-int.info
        - fahad-test6.tor.afilias-int.info
        - fahad-test7.tor.afilias-int.info
```

**NOTE:**
* hostnames: is required for the playbook to run. You cannot use other name without modifying the playbook.


4) Source our environment variable that I mentioned above.

```bash
    . ~/.ansible-env
```


5) Run Ansible with the following command or similar


```bash
    ansible-playbook -vv --diff -i tor/hosts deploy.yml -e @new-hosts.yml -uroot -k
```


**NOTE:**
* You will need to know the root password for the template you are using. Check in the password file.
* That's it. If everything goes well, I will have 7 VMs ready to be used.


## Configure(only) one or more VMs ( VM(s) must already be created ) 

### Run CN1 playbooks with root user

```bash
    ansible-playbook -i cn1/hosts site.yml -uroot -k
```

### Run CN2 playbooks with root user

```bash
    ansible-playbook -i cn2/hosts site.yml -uroot -k
```

### Run CN1 playbooks with a normal user and sudo(to root)

```bash
    ansible-playbook -i cn1/hosts site.yml -ufahad -bkK
```

### Run CN2 playbooks with root user. Run only sssd tag.

```bash
    ansible-playbook -i cn2/hosts site.yml -uroot -k -t sssd
```

### Run CN1 playbooks with root user. Run only smtp and snmp tag.

```bash
    ansible-playbook -i cn1/hosts site.yml -uroot -k -t smtp,snmp
```

### What Ansible tags have been defined in the playbooks

```bash
    ansible-playbook --list-tags site.yml
```

### Changed network settings(IP, MASK, GATEWAY, ROUTE ...) for mq1/2.cn2 boxes

```bash
    ansible-playbook -i cn2/hosts site.yml -l 'mq*' -uroot -k -t network
```

### Updated sudo access on DB and DAP boxes in both CN1 and CN2 sites'

```bash
    for i in 1 2; do ansible-playbook -i cn${i}/hosts site.yml -uroot -l db:dap -k -t sudo ; done
```

### Run Ansible without adding kerberos principal(in Kerberos) and ldap entry(in LDAP DB) for all IN1 boxes

```bash
    ansible-playbook -e 'nokrbprinc=1 noldapentry=1' -i in1/hosts site.yml -uroot -k
```

### Apply CIS on CN2 mq servers

```bash
    ansible-playbook -i cn2/hosts cis.yml -l 'mq*' -ufahad -bkK
```

### Also check out each role README for how to use them

