# vmware

Create VMware VM from a template for Afilias VMware environment. 

## Variable

The following Shell environment variables are needed on the system running Ansible

VMWARE_USER - user to login to VMware vCenter defined in default role variables

VMWARE_PASSWORD - password for the VMware user above

## Example host variables

    ---

    vm_name: parinya-test1

    num_cpus: 1
    num_cpu_cores_per_socket: 1
    memory_mb: 2048
    cluster: Cluster 1
    folder: STG TEST
    template: centos-7.5-x86_64-template

    disk:
        - size_gb: 32
          type: thin
          datastore: silverstore2-v5k1

    interfaces:
        - id: 0
          name: WebAdmin
          bootproto: none
          onboot: yes
          ip: 10.110.3.251
          prefix: 20
          dns_name: parinya-test1.stg.afilias-ops.info
          ipv6: yes
          gateway: 10.110.0.1

