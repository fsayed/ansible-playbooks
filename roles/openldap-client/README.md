# openldap-client role

This role configures openldap, pam_ldap and install required packages, create an LDAP host object

## Variables

ldap_basedn - LDAP basedn

ldap_uris - a list of LDAP URIs

default_members - a list of default users who should have access to the LDAP host (group var is recommended)

members - a list of users other than default users who should have access to the LDAP host (host var is recommended)

ldap_role - a list of LDAP roles (who can modify this host LDAP entry once it is created)


## Example

    ---
    ldap_basedn: dc=afilias, dc=info
    ldap_uris:
       - ldap://ldap3.tor.afilias-int.info
       - ldap://ldap4.tor.afilias-int.info

    default_members:
       - bkanagar
       - cchao
       - fsayed
       - gopal
       - gsp
       - kzhao
       - mpacyna
       - mwoodwal
       - parinya

    members:
       - nmofrad
       - fmosavat

    ldap_role: ['QA','DBA']

    OR

    ldap_role:
       - QA
       - DBA

