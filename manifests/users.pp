# == class graphite::users {

class graphite::users {
  if $graphite::user != undef {
    create_resources( nap_users::resource::user, $graphite::user)
  }
}

