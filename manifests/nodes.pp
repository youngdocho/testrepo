node /node.*/ {
 admin::cronjob { 'pull-updates':
    script_path => '/puppet/testrepo/pull-updates',
 }
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
  }
}

node /garb.*/ {
 admin::cronjob { 'pull-updates':
    script_path => '/puppet/testrepo/pull-updates',
 }
 class {'garb': 
    galera_servers  => hiera('galera_servers_array'),
    galera_group    => hiera('galera_group'),
 }
}

node 'haproxy' {
 admin::cronjob { 'pull-updates':
    script_path => '/puppet/testrepo/pull-updates',
 }
 class { 'haproxy': 
    server_nodes  => hiera('galera_servers_hash'), #required
    frontend_ip   => '192.168.0.13',               #required
 }
}
