# krb5-client role

This role configures /etc/krb5.conf and install krb5 client packages

## Variables

domain_realm - krb5 domain realm

krb5_realm - krb5 realm

krb5_admin_server - krb5 admin server

krb5_kdcs - a list of krb5 kdcs

## Example

    ---
    domain_realm: afilias.info
    krb5_realm: AFILIAS.INFO
    krb5_admin_server: ldapmaster-vm.tor.afilias-int.info
    krb5_kdcs:
       - ldap3.tor.afilias-int.info
       - ldap4.tor.afilias-int.info



