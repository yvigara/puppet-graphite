# == class: graphite::service

class graphite::service {

  service {$graphite::instance:
    ensure     => $graphite::start,
    enable     => $graphite::enable,
    hasrestart => true,
    hasstatus  => true
  }

}

