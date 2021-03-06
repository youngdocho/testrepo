class admin {
}

define admin::cronjob (
  $script_path,
  $minute = '*/10',
) {
  exec { 'script-copy':
    command => "/bin/cp ${script_path} /usr/local/sbin/${name}",
  }
  cron { "Run ${name}":
    command => "/usr/local/sbin/${name}",
    user    => 'root',
    minute  => $minute,
    require => Exec['script-copy'],
  }
}
