# iptables role

It's supposed to manage IPv4 iptables rules.

For now, it can only manages simple filter/nat table.

If no table is specified, assumed rules are for filter table.

If no chain is specified and no table specified, assumed rules are for filter table INPUT chain.

For nat table, you must specify both table and chain names

## Variables

    ---
    iptables_enabled: yes|no


    iptables_rules:
        - { proto: tcp, dport: 22 }
        - { src: 10.10.24.0/21, proto: tcp, dport: 80 }
        - { src: 10.10.24.0/21, proto: tcp, dport: 443 }
        - { src: 10.10.24.0/21, dst: 10.120.0.60, proto: tcp, dport: 53 }
        - { proto: tcp, dport: 22, comment: "Allow SSH" }
        - { src: "10.100.32.0/20", proto: tcp, dport: "5425:5533", comment: "From AU1 WR" }
        - { src: "10.120.32.0/20", proto: tcp, dport: "5425:5533", comment: "From AU1 DA" }
        - { src: "10.108.32.0/20", proto: tcp, dport: "5425:5533", comment: "From TX1 DA" }
        - { src: "10.109.32.0/20", proto: tcp, dport: "5425:5533", comment: "From ON1 DA" }
        - { src: "10.60.32.0/20", proto: tcp, dport: "5425:5533", comment: "From IN1 DA" }
        - { src: "10.111.32.0/20", proto: tcp, dport: "5425:5533", comment: "From IN3 DA" }
        - { src: "10.132.0.0/16", proto: tcp, dport: "5425:5533", comment: "From AU2 DA" }
        - { src: "10.0.0.0/8", proto: tcp, dport: [555,666,777,888,999], comment: "King KEN APPs MUST be allowed!" }
        - { src: 224.0.0.0/4 }


    iptables_filter_outbound: yes # This will DROP outgoing packets by default! You need to define your FILTER OUTPUT rules.


## More Rule Examples


Redirect incoming TCP traffic to port 514 to port 5140


    - { table: nat, chain: PREROUTING, proto: tcp, dport: 514, to_port: 5140, comment: "Redirect TCP 514 to 5140"}


Redirect incoming TCP traffic to interface eth0 to port 514 to 5140


    - { table: nat, chain: PREROUTING, in_inf: eth0, proto: tcp, dport: 514, to_port: 5140, comment: "Redirect TCP 514 to 5140"}


IP Masquerade on out going interface eth3


    - { table: nat, chain: POSTROUTING, out_inf: eth3}


Redirect TCP traffic


    - { table: nat, chain: PREROUTING, in_inf: eth0, proto: tcp, dport: 80, to: "10.120.0.100:80", comment: "Redirect HTTP traffic to 10.120.0.100:80"}



