#!/bin/bash

echo Welcome to the TuxCare ePortal Lets Encrypt Process.
echo
echo This script is current as of March, 2023
echo
echo
echo "Let's issue your Lets Encrypt SSL."
echo
echo "Enter the domain for the SSL Certificate."
read varDomain
echo Hostname selected: $varDomain, proceeding to install certbot...
sleep 3
yum install epel-release -y
yum install certbot python3-certbot-nginx -y
echo Issuing the SSL, but first, please enter your email address.
read varEmail
echo Email address: $varEmail
sleep 3
echo Installing the SSL..
certbot certonly --webroot --webroot-path /usr/share/nginx/html -m $varEmail --agree-tos -d $varDomain --key-type ecdsa --elliptic-curve secp384r1
echo Configuring nginx...
mv /etc/nginx/eportal.ssl.conf.example /etc/nginx/eportal.ssl.conf
grep -c "include eportal.ssl.conf;" /etc/nginx/conf.d/eportal.conf || sed -i "3i \ include eportal.ssl.conf;" /etc/nginx/conf.d/eportal.conf
sed -i -e "s|server_name.*|server_name $varDomain;|g" /etc/nginx/eportal.ssl.conf
sed -i -e "s|ssl_certificate .*|ssl_certificate /etc/letsencrypt/live/$varDomain/fullchain.pem;|" /etc/nginx/eportal.ssl.conf
sed -i -e "s|ssl_certificate_key .*|ssl_certificate_key /etc/letsencrypt/live/$varDomain/privkey.pem;|" /etc/nginx/eportal.ssl.conf
service nginx restart
echo Done!
echo You may visit your ePortal at https://$varDomain
