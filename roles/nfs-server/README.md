# nfs-server


Install / configure NFS server


## Variables


nfs_shares - Define shares (see example below)


## Example


    nfs_shares:
        - path: /opt/export/dotau-reports
          clients:
              - name: auepp1.au1.afilias-ops.info
                permission: ro,insecure

              - name: auepp2.au1.afilias-ops.info
                permission: ro,insecure

              - name: auepp3.au1.afilias-ops.info
                permission: ro,insecure

        - path: /var/www
          owner: apache
          group: apache
          mode: "0750"
          clients:
              - name: osrepo.tor.afilias-int.info
                permission: ro,insecure

              - name: bk1.tor.afilias-int.info
                permission: ro,no_root_squash



This will create the following /etc/exports


/opt/export/dotau-reports auepp1.au1.afilias-ops.info(ro,insecure)  auepp2.au1.afilias-ops.info(ro,insecure)  auepp3.au1.afilias-ops.info(ro,insecure) 

/var/www/html osrepo.tor.afilias-int.info(ro,insecure)  bk1.tor.afilias-int.info(ro,no_root_squash)

