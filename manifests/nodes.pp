node /node.*/{

  #include test
  #class {'test':
  #}
  #exec { 'copy-folder':
  #  command => '/bin/cp -r /vagrant/puppet/modules/* /etc/puppet/modules', 
  #}
  
  #exec { 'link-folder':
  #  command => '/bin/ln -s /vagrant/puppet/ /etc/puppet/modules/galera',
  #  require => Exec['copy-folder'],
  #}

  class { 'galera':
    galera_servers     => hiera('galera_servers_array'),
    wsrep_cluster_name => hiera('galera_group'),
    vendor_type        => 'mariadb',
    override_options   => {
      mysqld => {
        bind-address => '0.0.0.0',
      }
    },
    status_password => 'mariadb', #required
   # require => [Exec['copy-folder'], Exec['link-folder']],
  }
}

node /arb.*/{
  include garb
  class {'garb': 
    galera_servers  => hiera('galera_servers_array'),
    galera_group    => hiera('galera_group'),
  }
}

node 'haproxy'{
  include haproxy
  class { 'haproxy': 
     server_nodes  => hiera('galera_servers_hash'), #required
     frontend_ip   => '192.168.0.13',               #required
  }
}
