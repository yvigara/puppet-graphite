# == class: graphite::repo

class graphite::repo {

  # we will be using system_groups for legged deployments
  if $::system_group {
    $baseurl = "${graphite::repo_baseurl}/apps/${::system_role}/${::system_env}_${::system_group}"
  } else {
    $baseurl = "${graphite::repo_baseurl}/apps/${::system_role}/${::system_env}"
  }

  nap_yumrepo::repo { "apps-${::system_role}-${::system_env}":
    id      => "apps-${::system_role}-${::system_env}",
    baseurl => $baseurl,
    exclude => true,
    expire  => true,
  }

}

