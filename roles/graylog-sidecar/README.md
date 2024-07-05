# graylog-sidecar  role

Install graylog sidecar collector.

This role will use filebeat(default from sidecar).

## Variables

    ---
    graylog_api_url: https://mygraylog-server:9000/api/

    graylog_sidecar_tags:
        - linux


## Running

This role checks if graylog_sidecar variable is defined. If it's defined, the role will continue to execute.

So we can run our playbook with a simple command like:

    ansible-playbook -i tor/hosts -vv --diff site.yml -t graylog-sidecar -uroot -k -e graylog_sidecar=yes
