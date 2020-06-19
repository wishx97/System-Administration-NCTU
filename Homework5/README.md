# Homework 5
### Prerequisite
1. Create group
    ```shell
    pw groupadd GROUPNAME`
    ```
2. Create user
    ```shell
    sudo adduser
    ```
### NIS
#### Master Server
1. Add following to /etc/rc.conf
    ```shell
    rpcbind_enable="YES"
    nisdomainname="wishx97"
    nis_server_enable="YES"
    nis_client_enable="YES"
    nis_client_flags="-s -m -S wishx97,playground.com,pro.com"
    nis_yppasswdd_enable="YES"
    nis_yppasswdd_flags="-t /var/yp/src/master.passwd"
    ```
2. Change to NIS directory
   ```shell
   cd /var/yp
   ```
3. Edit Makefile
   ```shell
   #NOPUSH="true"
   $(YPSRCDIR)=/var/yp/src
   TARGETS= hosts group netgrp passwd master.passwd
   ```
4. Add ip and hostname to /etc/hosts
   ```shell
   192.168.207.4		pro.com
   192.168.207.5		playground.com
   ```
5. Copy hosts, group, master.passwd from /etc to /var/yp/src
6. Remove system account and root account in /var/yp/src/master.passwd
7. Start master server
    ```shell
    sudo ypinit -m wishx97
    ```
#### Slave Server
1. Add following to /etc/rc.conf
    ```shellrpcbind_enable="YES"
    nisdomainname="wishx97"
    nis_server_enable="YES"
    nis_client_enable="YES"
    nis_client_flags="-s -m -S wishx97,pro.com,playground.com"
    ```
2. Change to NIS directory
    ```shell
    cd /var/yp
    ```
3. Start slave server
    ```shell
    sudo ypinit -s pro.com wishx97
    ```
### NFS
#### Server
1. Add following to /etc/rc.conf
    ```shell
    nfs_server_enable="YES"
    nfs_server_flags="-u -t -n 4"
    nfsv4_server_enable="YES"
    nfsuserd_enable="YES"
    mountd_enable="YES"
    ```
2. Create a file named "exports" under /etc
3. Add following to /etc/exports
    ```shell
    V4: / -sec=sys -network 192.168.207.5 -mask 255.255.255.0
    /net/home -maproot=nobody -network 192.168.207.5 -mask 255.255.255.0
    ```
4. Create 2 zfs at /net/shares and /net/datas respectively
5. Set the "sharenfs" option of zfs
    ```shell
    zfs set sharenfs="-mapall=user:users -network 192.168.207.5 -mask 255.255.255.0" mypool/shares
    zfs set sharenfs="-ro -network 192.168.207.5 -mask 255.255.255.0" mypool/datas
    ```
#### Client
1. Add following to /etc/rc.conf
    ```shell
    nfsuserd_enable="YES"
    nfscbd_enable="YES"
    ```
### AutoFS(Bonus: auto_front map shared from NIS)
1. Add following to /etc/rc.conf
    ```shell
    autofs_enable="YES"
    ```
2. Create a file named auto.nas under /etc
3. Add the following to /etc/auto.nas
    ```shell
    +auto_front
    ```
4. Add the following to /etc/auto_master
    ```shell
    /net        /etc/auto.nas
    ```
### Finishing
#### Sudoers
1. Create a file named sudoers under/net/datas
2. Add the following to /net/datas/sudoers
    ```shell
    ##
    ## Cmnd alias specification
    ##
    Cmnd_Alias SHELLS=/bin/sh,/bin/tcsh,/bin/csh,/usr/local/bin/tcsh,\
                      /usr/local/bin/ksh,/usr/local/bin/bash,\
                      /usr/bin/sh,/usr/bin/tcsh,/usr/bin/csh,/usr/bin/bash,/bin/zsh,\
                      /usr/local/bin/zsh

    ##
    ## User privilege specification
    ##
    %acctadm ALL=(ALL)ALL, !SHELLS
    %storadm ALL=(ALL)ALL, !SHELLS
    ```
#### Netgroup
1. Format
    ```shell
    NETGROUP_NAME (HOST_NAME,USER_NAME,DOMAIN_NAME)
    ```
#### hosts.allow
* To allow only login from playground to pro
1. Edit /etc/hosts.allow
2. Add the following before the line **ALL : ALL : allow**
    ```shell
    sshd : playground.com : allow
    sshd : ALL : deny
    ```
#### Include configuration from NIS
1. Add the following at the end of /etc/master.passwd
    ```shell
    +::::::::: # Add all user from NIS
    +@NETGROUP_NAME::::::::: # Add only user from NETGROUP_NAME
    +:::::::::/sbin/nologin # Without login
    ```
2. Add the following at the end of /etc/group
    ```shell
    +:*:: # Add all group from NIS
    ```
