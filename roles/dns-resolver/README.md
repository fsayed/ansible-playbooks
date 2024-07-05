# dns-resolver role

This role configures /etc/resolv.conf and /etc/hosts

## Variables

dhs_search - DNS search list

dns_servers - list of DNS server IPs

etc_hosts - list of IPs and hostnames to populate in /etc/hosts

## Example

    ---
    dns_search: tor.afilias-int.info afilias-int.info
    dns_servers:
        - 10.10.32.17
        - 10.10.32.37

    etc_hosts:
        - '10.10.24.80': ['parinya.tor.afilias-int.info', 'parinya']
        - '8.8.8.8': ['google-public-dns-a.google.com', 'google-dns-1']


