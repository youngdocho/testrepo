# Manage HAProxy
class haproxy(
  $server_nodes,  
  $frontend_ip,
  $auth_id        = 'admin',
  $auth_password  = 'password', 
  $healthchk_port = '80',
  $xinetd_port    = '9200',
  $balancer_port  = '3306',
  $balance        = 'roundrobin',
  $mode           = 'tcp', 
)
{
  include apt
  apt::ppa {'ppa:vbernat/haproxy-1.6': }

  exec {'apt-update':
    command => '/usr/bin/apt-get update',
    refreshonly => true,
    require => Apt::Ppa['ppa:vbernat/haproxy-1.6'],
  }

  package { 'haproxy': 
    ensure => installed,
    require => Exec['apt-update'],
  }
 
  Apt::Ppa['ppa:vbernat/haproxy-1.6'] -> Package<| provider == 'apt' |>
 
  file { '/etc/default/haproxy':
    content => "ENABLED=1\n",
    require => Package['haproxy'],
  }

  service { 'haproxy':
    ensure => running,
    enable => true,
    require => Package['haproxy'],
  }

  $frontend = "${::hostname}_${frontend_ip}_${balancer_port}" 
  file { '/etc/haproxy/haproxy.cfg':
    content => template('haproxy/haproxy.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }
}
