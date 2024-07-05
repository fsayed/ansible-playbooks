# puppet-client role

Role to configure puppet agent for Red Hat/CentOS 6.x

## Variables

pe_version - (optional)Puppet version to setup yum repository, default is 2.7.0

puppet_yum_base_url: (optional) default to http://osrepo.tor.afilias-int.info/project_repos

puppetmaster - (optional)Puppet master node, default is using puppet_environment to identify one
