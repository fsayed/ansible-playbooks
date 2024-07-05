# ip6tables role

It's supposed to manage IPv6 iptables rules.

For now, it can only manages simple INPUT chain in the filter table.

## Variables

    ---
    ip6tables_enabled: yes|no


    ip6tables_rules:
        - { proto: tcp, dport: 22 }
        - { proto: tcp, dport: 53 }
        - { proto: tcp, dport: 80 }
        - { proto: tcp, dport: 443 }
        - { proto: tcp, dport: "5425:5533", comment: "Postgres" }
        - { proto: tcp, dport: [555,666,777,888,999], comment: "King KEN APPs MUST be allowed!" }

