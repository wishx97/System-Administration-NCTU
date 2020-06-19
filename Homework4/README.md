# Homework 4
1. Set up VirtualBox NAT port forwarding
2. Get a domainname and register it with your machine public IP
![Port Forwarding on VirtualBox](/images/Homework4/vbox_port_forward.png)
### Apache
1. Add the following in /etc/rc.conf
    ```shell
    apache24_enable="YES"
    ```
2. Install apache24 by pkg
    ```shell
    sudo pkg install apache24
    ```
#### Virtual Hosts & AutoDirect
1. Change directory to /usr/local/etc/apache24/extra
2. Add the following to  httpd-vhosts.conf
    ```shell
    <VirtualHost *:8080> # 8080 is the port set for HTTP
        # visit by IP
        DocumentRoot "/usr/local/www/apache24/data"
    </VirtualHost>

    <VirtualHost *:8080>
        # visit by domain name wishx97.nctucs.net
        DocumentRoot "/usr/local/www/apache24/wishx97_nctu_me"
        ServerName wishx97.nctucs.net
        # auto-direct implementation by rewrite rule
        RewriteEngine On
        RewriteRule  ^(.*) https://wishx97.nctucs.net:8443$1 [R,L]
    </VirtualHost>
    ```
* Change directory to /usr/local/etc/apache24
#### Indexing 
1. Add the following to  httpd.conf
    ```shell
    <Directory "/usr/local/www/apache24/wishx97_nctu_me">
      Options Indexes FollowSymLinks
      AllowOverride None
      Require all granted
    </Directory>
    ```
#### htaccess
1. Add the following to  httpd.conf
    ```shell
    <Location "/admin"> # Password required when visit "/admin"
      AuthType Basic
      AuthName "Please input admin password"
      AuthUserFile /var/.htpasswd
      Require valid-user
    </Location>
    ```
#### Reverse Proxy
1. Add the following to  httpd.conf
    ```shell
    ProxyRequests Off 
    <Proxy "balancer://mycluster"> # Cluster of proxy server
    BalancerMember http://sahw4-loadbalance1.nctucs.net
    BalancerMember http://sahw4-loadbalance2.nctucs.net/
    </Proxy>
    <Location "/reverse">
      ProxyPreserveHost On 
      # Both line below must exist
      ProxyPass "balancer://mycluster"
      ProxyPassReverse "balancer://mycluster"
    </Location>
    ```
#### Hide Server Token
1. Change directory to /usr/ports/www/mod_sercurity
    ```shell
    make all
    make install
    ```
2. Uncomment the following in /usr/local/etc/apache24/modules.d
    ```shell
    LoadModule unique_id_module libexec/apache24/mod_unique_id.so
    LoadModule security2_module libexec/apache24/mod_security2.so
    Include /usr/local/etc/modsecurity/*.conf
    ```
3. Add the following to httpd.conf
    ```shell
    ServerTokens Full
    SecServerSignature GetLOST
    ```
#### SSL
1. Uncomment the following in httpd.conf
    ```shell
    LoadModule socache_shmcb_module libexec/apache24/mod_socache_shmcb.so
    LoadModule ssl_module libexec/apache24/mod_ssl.so
    Include etc/apache24/extra/httpd-ssl.conf
    ```
2. Edit the file /usr/local/etc/apache24/extra/httpd-ssl.conf
    ```shell
    ## SSL Virtual Host Context
    <VirtualHost _default_:8443>
    #   General setup for the virtual host
    DocumentRoot "/usr/local/www/apache24/wishx97_nctu_me"
    ServerName wishx97.nctucs.net
    ServerAdmin you@example.com
    ErrorLog "/var/log/httpd-error.log"
    TransferLog "/var/log/httpd-access.log"
    ```
3. Follow the instruction at [Let's Encrypt - Free SSL/TLS Certificates](https://letsencrypt.org/) to create a certificate
### Nginx
1. Add the following in /etc/rc.conf
      ```shell
      nginx_enable="YES"
      ```
2. Install nginx by pkg
    ```shell
    sudo pkg install nginx
    ```
* Change directory to /usr/local/etc/nginx*
#### Virtual Hosts & AutoDirect
1. Edit the following in nginx.conf
    ```shell
    # another virtual host using mix of IP-, name-, and port-based configuration
    server {
        listen 80;
        server_name wishx98.nctucs.net;
        rewrite ^(.*) https://wishx98.nctucs.net$1 permanent;
    }
    ```
#### Indexing 
1. Add the following to  Virtual Host in nginx.conf
   ```shell
   autoindex on;
   ```
#### htaccess
1. Add the following to  nginx.conf
    ```shell
    location /admin/ {
                alias /usr/local/www/apache24/wishx98_nctu_me/admin/;
                auth_basic "Restricted Content";
                auth_basic_user_file /var/.htpasswd;
    }
    ```
#### Reverse Proxy
1. Add the following to  nginx.conf
    ```shell
    upstream myapp1 {
	    server sahw4-loadbalance1.nctucs.net;
	    server sahw4-loadbalance2.nctucs.net;
    }
    # Write the following in server{}
    location /reverse/ {
      proxy_pass http://myapp1/;
    }
    ```
#### Hide Server Token
1. Add the following to  nginx.conf
    ```shell
    server_tokens off;
    ```
#### SSL
1. Add the following in Virtual Hosts without https in nginx.conf
    ```shell
    rewrite ^(.*) https://wishx98.nctucs.net$1 permanent;
    ```
2. Follow the instruction at [Let's Encrypt - Free SSL/TLS Certificates](https://letsencrypt.org/) to create a certificate

