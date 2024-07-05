# cron-access role

Control who can run cron and at(unix at) basically it will create a /etc/cron.allow

/etc/cron.deny will be ignored if there is /etc/cron.allow so we will not configure it.

## Variables

    ---
    cron_access_enabled: yes|no

    cron_users:
        - root
        - parinya
        - kingken

    at_users:
        - root
        - parinya
        - kingken


## NOTE

root user can always use cron anyway no matter what but we will just use it as an example.

at_users is not required and if it is not defined, it will use cron_users instead.

