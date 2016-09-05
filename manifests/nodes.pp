node /node.*/{
  
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

node /garb.*/{
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
