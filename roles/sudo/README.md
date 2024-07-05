# sudo role

This role creates /etc/sudoers.d/ansible file according to:

group variable: default_sudo_specs

host variable: sudo_specs(see below)

## Variables

default_sudo_specs - a list of default sudo specs for all hosts in the same group. 

sudo_specs - a list of sudo specs specifically for the particular host.

## Example

group var:

    ---
    default_sudo_specs:
        - type: permission
          user: '%syseng'
          host: ALL
          runas: ALL
          command: ALL

        - type: permission
          user: '%neteng'
          host: ALL
          runas: ALL
          command: ALL
    
        - type: permission
          user: '%noc'
          host: ALL
          runas: ALL
          command: '/bin/su - nagios, /bin/su - zenmon, /etc/init.d/nrpe restart'


host var:

    ---
    sudo_specs:
        - type: permission
          user: 'parinya'
          host: ALL
          runas: ALL
          command: ALL
    
        - type: alias
          alias_type: Cmnd_Alias
          name: DBA_CMND_ANSIBLE
          value: '/bin/su - postgres, /usr/local/bin/puppet, /opt/puppet/bin/puppet'
    
        - type: permission
          user: '%dba'
          command: DBA_CMND_ANSIBLE


Ansible sudo role will create:

    # From ansible default_sudo_specs group variable
    %syseng ALL = (ALL)  ALL
    
    %neteng ALL = (ALL)  ALL
    
    %noc ALL = (ALL)  /bin/su - nagios, /bin/su - zenmon, /etc/init.d/nrpe restart
    
    # From ansible sudo_specs host variable
    parinya ALL = (ALL)  ALL
    
    Cmnd_Alias DBA_CMND_ANSIBLE = /bin/su - postgres, /usr/local/bin/puppet, /opt/puppet/bin/puppet
    
    %dba ALL = (ALL)  DBA_CMND_ANSIBLE


More examples:

    ---
    sudo_specs:
        - type: alias
          alias_type: Cmnd_Alias
          name: NETWORKING
          value: '/sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /sbin/iwconfig, /sbin/mii-tool'
    
        - type: alias
          alias_type: User_Alias
          name: OPS
          value: 'parinya, fsayed'
    
        - type: permission
          user: '%syseng'
          host: ALL
          runas: ALL
          nopasswd: no
          command: ALL
    
        - type: permission
          user: OPS
          nopasswd: yes
          command: NETWORKING


