# dns-slave role

This role configures named as slave for Afilias OPS servers. Bluecat is master.

## Requirements

python suds and netaddr modules installed where you are running Ansible(e.g. your workstation)

on my Fedora, I can do:

    dnf install python2-suds python-netaddr

## Shell variables

BLUECAT_USER - user to login to Afilias BlueCat DNS server

BLUECAT_PASSWORD - password for the BlueCat user above

## Ansible variables

dns_slave_zones - a list of zones to be replicated from Bluecat

If dns_slave_zones is not defined, we query all internal zones from Bluecat and replicate them all.

## Examples

    dns_slave_zones:
        - afilias-int.info
        - afilias-ops.info
        - tor.afilias-int.info
        - on1.afilias-ops.info
        - tx1.afilias-ops.info
        - au1.afilias-ops.info
        - 0.10.10.in-addr.arpa
        - 24.10.10.in-addr.arpa
        - 32.10.10.in-addr.arpa
        - 108.10.10.in-addr.arpa
        - 109.10.10.in-addr.arpa
        - 120.10.in-addr.arpa

## Usage

If you are not going to replicate all internal zones from Bluecat, you have to define "dns_slave_zones" variable somewhere.

For example I assumed you have created a YAML file names zones.yml that contains "dns_slave_zones" like the example above.

Next you have to create a playbook for example: dns-slave.yml

    ---
    - hosts: all
      roles:
          - { role: dns-slave }


So we can run our playbook with command like:

    ansible-playbook -i 10.120.0.60,10.120.0.61, -vv --diff dns-slave.yml -uroot -k -e @zones.yml

OR

we can run our playbook to slave all internal zones from Bluecat (We don't need to specify dns_slave_zones)

    ansible-playbook -i 10.120.0.60,10.120.0.61, -vv --diff dns-slave.yml -uroot -k


I provided these files in "examples" folder under dns-slave role.
