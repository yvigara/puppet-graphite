# == class graphite::users {

class graphite::users {

  $gid = uid_gen($graphite::gr_group)
  $uid = uid_gen($graphite::gr_user)
  group { $graphite::gr_group:
    ensure  => present,
    gid     => $gid,
  } ->
  user { $graphite::gr_user:
    ensure     => present,
    uid        => $uid,
    gid        => $gid,
    home       => '/var/lib/carbon',
    comment    => 'Carbon cache daemon',
    shell      => '/sbin/nologin',
    managehome => false,
  }
}

