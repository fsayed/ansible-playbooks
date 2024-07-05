# nfs-client


Mounts nfs filesystem, adds it to /etc/fstab and creates a symlink if requested


## Variables

nfs_client_mounts - Defines the filesytem to be nfs mounted


## Example

nfs_client_mounts:
 - path: /opt/OXRS/info-reports-rep1
   src: nfs-test-1.syseng.acs.afilias-int.info:/opt/export/dotinfo-reports
   symlink_dest: /opt/OXRS/info-reports


This will create the directory /opt/OXRS/info-reports-rep1 (if it doesn't exist) and then mount /opt/export/dotinfo-reports nfs export from nfs-test-1.syseng.acs.afilias-int.info with the default mount options (in defaults/main.yml nfs_client_mount_opts variable) and create an entry in /etc/fstab:

$ grep nfs /etc/fstab 
nfs-test-1.syseng.acs.afilias-int.info:/opt/export/dotinfo-reports /opt/OXRS/info-reports-rep1 nfs4 ro,retry=3,rsize=32768,nodev,nosuid,sec=sys 0 0

It will also create a symlink to that directory:

$ ls -l /opt/OXRS/info-reports
lrwxrwxrwx. 1 root root 27 Jan  8 17:11 /opt/OXRS/info-reports -> /opt/OXRS/info-reports-rep1

If you don't need a symlink then you can just omit that option entirely:

nfs_client_mounts:
 - path: /opt/OXRS/info-reports-rep1
   src: nfs-test-1.syseng.acs.afilias-int.info:/opt/export/dotinfo-reports
