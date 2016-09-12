define cron_job (
  $script_path,
  $minute = '*/10',  
) {
  exec { 'script-copy':
    command => "/bin/cp ${script_path} /usr/local/sbin/${name}",    
    ensure  => present,
  }
  cron { "Run ${name}":
    command => "/usr/local/sbin/${name}",
    user    => 'root',
    minute  => $minute',
  }
}

node /node.*/ {
 cron_job { 'pull-updates':
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
 cron_job { 'pull-updates':
    script_path => '/puppet/testrepo/pull-updates',
 }
 class {'garb': 
    galera_servers  => hiera('galera_servers_array'),
    galera_group    => hiera('galera_group'),
 }
}

node 'haproxy' {
 cron_job { 'pull-updates':
    script_path => '/puppet/testrepo/pull-updates',
 }
 class { 'haproxy': 
    server_nodes  => hiera('galera_servers_hash'), #required
    frontend_ip   => '192.168.0.13',               #required
 }
}
