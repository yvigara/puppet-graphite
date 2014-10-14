# == class graphite::users {

class graphite::users {

  $gid = uid_gen($graphite::group)
  $uid = uid_gen($graphite::user)
  group { $graphite::group:
    ensure  => present,
    gid     => $gid,
  } ->
  user { $graphite::user:
    ensure     => present,
    uid        => $uid,
    gid        => $gid,
    home       => "/home/${graphite::user}",
    comment    => 'Graphite User',
    shell      => '/bin/false',
    managehome => true,
  }
}

