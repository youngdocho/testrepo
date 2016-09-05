#!/bin/bash
cd /puppet/testrepo
git add .
git pull
chmod 700 puppet.sh

cp -r /puppet/testrepo/modules/* /etc/puppet/modules
ln -s /puppet/testrepo/ /etc/puppet/modules/galera/
echo 'user localhost=(root) NOPASSWD: /sbin/iptables -vnxL' >> /etc/sudoers
puppet apply /puppet/testrepo/manifests/nodes.pp --hiera_config=/puppet/testrepo/hiera.yaml

if hostname | grep ^node* > /dev/true; then
  service xinetd start
fi 
