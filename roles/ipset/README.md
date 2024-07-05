ipset role
=========

Ansible role to install and create empty ipsets (used by iptables/ip6tables and fttpull roles).
Needs to run before iptables so that if there are any rules using ipsets it won't fail.

Role Variables
--------------

create an ipset named epp_prod_inet of a type hash:net to hold ipv4 addresses
also create ipset named epp_prod_inet6 of a type hash:net to hold ipv6 addresses

ipset_set:
    - name: epp_prod_inet
      type: 'hash:net'
      inet_family: inet

    - name: epp_prod_inet6
      type: 'hash:net'
      inet_family: inet6

