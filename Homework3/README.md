# Homework 3
### Pureftpd
1. Install pureftpd by ports
    ```shell
    cd /usr/ports/ftp/pure-ftpd/
    make install clean
    rehash
    ```
2. Tick the upload script option during installation
3. Copy sample .conf file
    ```shell
    cp /usr/local/etc/pure-ftpd.conf.sample /usr/local/etc/pure-ftpd.conf
    ```
#### Annonymous login
1. Create a user and group named ftp
    ```shell
    pw groupadd ftp
    pw useradd ftp -g 14 -d /var/ftp -s /sbin/nologin
    ```
2. Edit /usr/local/etc/pure-ftpd.conf
    ```shell
    Umask                        107:000
    NoAnonymous     no
    AnonymousCanCreateDirs       yes
    AnonymousCantUpload          no
    ```
3. Edit permission for for required directory

    ![Directory permission](/images/Homework3/permission.png)

4. Add the following to /etc/rc.conf
    ```shell
    pureftpd_enable="YES"
    # line below enable self-written script named ftp_watchd
    ftp_watchd_enable="YES"
    ftp_watchd_command="zbackup mypool/upload 10"
    ```
#### Virtual User
1. Use a system account to create new virtual user
    ```shell
    # create virtual user using system account wishx97
    pure-pw useradd akari -u vftp -g wishx97 -d /home/vftp/akari
    Password: TYPE YOUR PASSWORD
    # MUST UPDATE DATABASE
    pure-pw mkdb
    ```
### TLS
1. Generate self-signed certificate
    ```ssl
    cd /etc/ssl/
    mkdir private
    cd private/
    openssl req -x509 -nodes -newkey rsa:2048 -sha256 -keyout \
    /etc/ssl/private/pure-ftpd.pem \
    -out /etc/ssl/private/pure-ftpd.pem
    ```
### ZFS
1. Add the following to /etc/rc.conf
    ```shell
    zfs_enable="YES"
    # line below enable self-written script named zbackupd
    zbackupd_enable="NO"
    zbackupd_config="sdsafs"
    ```
2. Create mirror zpool and dataset
    ```shell
    zpool create mypool mirror /dev/ada1 /dev/ada2
    zfs create -o compress=gzip -o mountpoint=/usr/home/ftp/public mypool/public
    zfs create -o compress=gzip -o mountpoint=/usr/home/ftp/upload mypool/upload
    zfs create -o compress=gzip -o mountpoint=/usr/home/ftp/treasure mypool/treasure
    ```

