# tcpwrappers role

It manages /etc/hosts.allow and /etc/hosts.deny

## Variables

    ---
    tcpwrappers_enabled: yes|no

    hosts_allow:
        - { daemon: ALL, client: "127.0., [::1]" }
        - { daemon: sshd, client: ALL }

    hosts_deny:
        - { daemon: ALL, client: ALL }

