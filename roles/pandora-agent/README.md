# pandora-agent role

This role install pandora agent

## Variables

pandora_yum_base_url: http://osrepo.tor.afilias-int.info/project_repos/afilias-extras

remote_config_value: 1

pandora_user/pandora_group: nocmon

pandora_servers:
  tx1: 10.108.0.246
  tx1da: 10.108.32.246
  on1: 10.109.0.246
  on1da: 10.109.32.246
  tor: 10.10.32.246
  stg: 10.10.32.248
  cn1: 10.115.0.246
  cn1da: 10.115.32.246
  cn2: 10.118.0.246
  cn2da: 10.115.32.246
  ay1: 172.16.21.17
  aws1: 10.113.1.21
  aws2: 10.112.1.21
  phl: 10.11.208.246 
  default: 0.0.0.0

pandora_server: "{{ pandora_servers[pandora_svr] if pandora_servers[pandora_svr] is defined else pandora_servers['default'] }}"

pandora_agent: /usr/bin/pandora_agent

usr_share_pandora_agent: /usr/share/pandora_agent

## Tags available for this role

pandora, pandora-agent, pandora-restart

## Example

    ---
To install Pandora agent and update sudoers file for NOC:

ansible-playbook -i stg/hosts  site.yml -l ldap3.stg.afilias-ops.info  -s -k -K -t sudo,pandora


To restart Pandora agent only on a host or group of hosts:

ansible-playbook -i stg/hosts site.yml -l ops  -s -k -K -t pandora-restart


