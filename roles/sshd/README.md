# ssh role

Configured sshd_config

## Variables and Examples

    cloud:
        admin_username: centos

    sshd_config: 
        LogLevel: INFO
        MaxAuthTries: 4
        LoginGraceTime: 60
        ClientAliveInterval: 300
        ClientAliveCountMax: 0
        AuthorizedKeysFile: /etc/ssh/keys/%u/authorized_keys
        Match:
            - rule: User {{ cloud.admin_username }} Address 10.10.0.0/16,10.11.0.0/16
              config:
                  - "{{ 'RequiredAuthentications2 publickey' if ansible_distribution_major_version|int <= 6 else 'AuthenticationMethods publickey' }}"


