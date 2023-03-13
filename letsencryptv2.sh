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
# Determine the Linux distribution
if [ -f /etc/redhat-release ]; then
  DISTRIBUTION="Red Hat"
elif [ -f /etc/lsb-release ]; then
  DISTRIBUTION="Ubuntu"
  UBUNTU_VERSION=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d "=" -f 2)
fi

# Execute commands based on the Linux distribution
if [ "$DISTRIBUTION" = "Red Hat" ]; then
  # Execute commands for Red Hat
yum install snapd
systemctl enable --now snapd.socket
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
  # Add your commands here for Red Hat
elif [ "$DISTRIBUTION" = "Ubuntu" ]; then
  # Execute commands for Ubuntu
  if [ "$(echo $UBUNTU_VERSION'<'20.04 | bc -l)" -eq 0 ] && [ "$(echo $UBUNTU_VERSION'<'22.04 | bc -l)" -eq 1 ]; then
    # Execute commands for Ubuntu 20.04
snap install core; snap refresh core
snap install --classic certbot
    # Add your commands here for Ubuntu 20.04
  else
    # Execute commands for Ubuntu 22.04 or later
snap install core; snap refresh core
snap install --classic certbot
    # Add your commands here for Ubuntu 22.04 or later
  fi
else
  echo "Unsupported distribution detected"
fi
echo Issuing the SSL, but first, please enter your email address.
read varEmail
echo Email address: $varEmail
sleep 3
echo Installing the SSL..
certbot certonly --nginx -m $varEmail --agree-tos -d $varDomain --key-type ecdsa --elliptic-curve secp384r1
echo Configuring nginx...
mv /etc/nginx/eportal.ssl.conf.example /etc/nginx/eportal.ssl.conf
grep -c "include eportal.ssl.conf;" /etc/nginx/conf.d/eportal.conf || sed -i "3i \ include eportal.ssl.conf;" /etc/nginx/conf.d/eportal.conf
sed -i -e "s|server_name.*|server_name $varDomain;|g" /etc/nginx/eportal.ssl.conf
sed -i -e "s|ssl_certificate .*|ssl_certificate /etc/letsencrypt/live/$varDomain/fullchain.pem;|" /etc/nginx/eportal.ssl.conf
sed -i -e "s|ssl_certificate_key .*|ssl_certificate_key /etc/letsencrypt/live/$varDomain/privkey.pem;|" /etc/nginx/eportal.ssl.conf
service nginx restart
echo Done!
echo You may visit your ePortal at https://$varDomain
