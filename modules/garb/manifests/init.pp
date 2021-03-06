# Manage Galera Arbitrator
class garb(
  $galera_servers     = [$::ipaddress_eth1],
  $galera_group       = 'mariadb_cluster',
)
{
  include apt

  apt::source{ 'ubuntu-galera':
    location => 'http://mirror.aarnet.edu.au/pub/MariaDB/repo/10.1/ubuntu',
    repos    => 'main',
    release  => $::lsbdistcodename,
    key      => {
      'id'    => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
      'server'=> 'keyserver.ubuntu.com', 
    },
    include  => {
      'src'   => false,
      'deb'   => true,
    }
  }

  package { 'galera-arbitrator-3': 
    ensure => installed,
    require => Apt::Source['ubuntu-galera'],
  }

  Apt::Source['ubuntu-galera'] -> Package<| provider == 'apt' |>
 
  $galera_nodes = join(suffix($galera_servers, ':4567'), ' ')
  
  file { '/etc/default/garb':
    mode    => 'a+w',
    content => template('garb/garb.erb'),
    require => Package['galera-arbitrator-3'],
  }

  exec { 'default-garb':
    command => 'update-rc.d -f garb defaults',
    path => '/usr/sbin/',
    require => File['/etc/default/garb'],
  }

  service { 'garb':
    ensure => running,
    enable => true,
    require => Exec['default-garb'],
  }

}
