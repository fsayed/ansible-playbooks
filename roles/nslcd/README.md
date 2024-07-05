# nslcd role

This role configures nslcd to use kerberos and ldap

## Variables

ldap_client_type: nslcd

ldap_basedn - LDAP basedn

ldap_uris - a list of LDAP URIs


domain_realm - krb5 domain realm

krb5_realm - krb5 realm

krb5_admin_server - krb5 admin server

krb5_kdcs - a list of krb5 kdcs

## Example

    ---
    ldap_basedn: dc=afilias, dc=info
    ldap_uris:
       - ldap://ldap3.tor.afilias-int.info
       - ldap://ldap4.tor.afilias-int.info

    domain_realm: afilias.info
    krb5_realm: AFILIAS.INFO
    krb5_admin_server: ldapmaster-vm.tor.afilias-int.info
    krb5_kdcs:
       - ldap3.tor.afilias-int.info
       - ldap4.tor.afilias-int.info

