node 'base' {
  exec { 'script-copy':
    path    => '/puppet/testrepo/pull-updates',
    ensure  => present,
    command => '/bin/cp /puppet/testrepo/pull-updates /usr/local/sbin/pull-updates',    
  }
  cron { 'pull-updates':
    command => '/usr/local/sbin/pull-updates',
    user    => 'root',
    minute  => '*/10',
    require => Exec['script-copy'],
  }
}

node /node.*/ inherits 'base'{
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

node /garb.*/ inherits 'base'{
  class {'garb': 
    galera_servers  => hiera('galera_servers_array'),
    galera_group    => hiera('galera_group'),
  }
}

node 'haproxy' inherits 'base'{
  class { 'haproxy': 
     server_nodes  => hiera('galera_servers_hash'), #required
     frontend_ip   => '192.168.0.13',               #required
  }
}
