# == class: graphite::package

class graphite::package {

  package{'graphite-web':
    ensure => latest,
  }
  package{'python-carbon':
    ensure => latest,
  }
  package{'python-bucky':
    ensure => latest,
  }
  package{'python-whisper':
    ensure => latest,
  }

}

