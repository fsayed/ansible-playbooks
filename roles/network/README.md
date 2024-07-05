# network role

Configure hostname, dns resolver and network interfaces and routes

## Variables

interfaces - a list of interface configurations (see an example below)

## Example 1

    ---
    interfaces:
        - id: 0
          type: Ethernet
          bootproto: none
          onboot: yes
          ip: 172.25.10.181
          prefix: 24
          ipv6: yes
          gateway: 172.25.10.1
          routes:
              - network: 100.0.0.0/24
                gateway: 172.25.10.5
              - network: 150.0.0.0/24
                gateway: 172.25.10.5
              - network: 160.0.0.0/24
                gateway: 172.25.10.5
              - network: 200.0.0.0/24
                gateway: 172.25.10.10

        - id: 1
          type: Ethernet
          bootproto: none
          onboot: yes
          ip: 172.25.50.181
          prefix: 24
          ipv6: yes
          routes:
              - network: 230.0.0.0/24
                gateway: eth1
          ip6: 2001:250:222:b3::35:10/64
          routes6:
              - network: 2001:1978:801::0/48
                gateway: 2001:250:222:b3::1
              - network: 2001:1900:2262::0/48
                gateway: 2001:250:222:b3::1
              - network: 2001:500:109::0/48
                gateway: 2001:250:222:b3::1
              - network: 2001:250:222:a3::0/64
                gateway: 2001:250:222:b3::1

## Example 2

    ---
    interfaces:
        - id: 0
          type: Ethernet
          bootproto: none
          onboot: yes
          ip: 10.115.3.10
          prefix: 20
          ipv6: yes
          routes:
              - network: 10.0.0.0/8
                gateway: 10.115.0.1

        - id: 1
          type: Ethernet
          bootproto: none
          onboot: yes
          ip: 10.100.35.10
          prefix: 20
          ipv6: yes
          routes:
              - network: 10.100.48.0/20
                gateway: 10.100.32.1

        - id: 2
          type: Ethernet
          bootproto: none
          onboot: yes
          ip: 10.100.3.10
          prefix: 20
          gateway: 10.100.0.5
          ipv6: yes
          ip6: 2001:250:222:a::3:10/64 
          gateway6: 2001:250:222:a::1
          ip_aliases:
              - ip: 10.100.3.30
                prefix: 20
          ip6_aliases:
              - 2001:250:222:a::3:30/64



## Example 3

    Ansible will not touch the network interface settings

    ---
    interfaces:


