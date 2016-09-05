#!/bin/bash
cd /puppet
git add testrepo/hieradata/common.yaml
git add testrepo/puppet.sh
git pull https://github.com/youngdocho/testrepo.git
chmod 700 testrepo/puppet.sh

cp -r /puppet/testrepo/modules/* /etc/puppet/modules
ln -s /puppet/testrepo/ /etc/puppet/modules/galera/
echo 'user localhost=(root) NOPASSWD: /sbin/iptables -vnxL' >> /etc/sudoers
puppet apply /puppet/testrepo/manifests/nodes.pp --hiera_config=/puppet/testrepo/hiera.yaml

if hostname | grep ^node* > /dev/true; then
  service xinetd start
fi 
