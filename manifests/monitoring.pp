# == class: graphite::monitoring

class graphite::monitoring {

  if $nap_nagios::enable {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

# ensure you use ensure => $ensure for each nagios::check entry

}

