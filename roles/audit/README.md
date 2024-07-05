# audit role

Configure auditd.

More info on how each Red Hat/CentOS versions handle configurations

https://access.redhat.com/solutions/2211891


## NOTE

Please note that we need to pass audit=1 to kernel in order get proper results. This role will not do that for you.

See auditd(8).

## TODO

Too many things. For example:

Make many auditd options as Ansible options.

Fine tune more auditing syscalls / commands.


