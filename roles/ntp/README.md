# ntp role

This role install ntp and configures /etc/ntpd.conf

## Variables

ntp_servers - list of ntp servers

## Example

    ---
    ntp_servers:
        - 0.ca.pool.ntp.org
        - 1.ca.pool.ntp.org


