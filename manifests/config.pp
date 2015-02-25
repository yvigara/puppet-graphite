# == Class: graphite::config
#
# This class configures graphite/carbon/whisper and SHOULD NOT
# be called directly.
#
# === Parameters
#
# None.
#
class graphite::config {
  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  # for full functionality we need this packages:
  # mandatory: python-cairo, python-django, python-twisted,
  #            python-django-tagging, python-simplejson
  # optional:  python-ldap, python-memcache, memcached, python-sqlite

  # we need an web server with python support
  # apache with mod_wsgi or nginx with gunicorn
  case $graphite::gr_web_server {
    'apache': {
      include graphite::config_apache
      $web_server_package_require = [Package[$::graphite::params::apache_pkg]]
    }

    'nginx': {
      # Configure gunicorn and nginx.
      include graphite::config_gunicorn
      include graphite::config_nginx
      $web_server_package_require = [Package['nginx']]
    }

    'wsgionly': {
      # Configure gunicorn only without nginx.
      include graphite::config_gunicorn
      $web_server_package_require = undef
    }

    'none': {
      # Don't configure apache, gunicorn or nginx. Leave all webserver configuration to something external.
      $web_server_package_require = undef
    }

    default: {
      fail('The only supported web servers are \'apache\', \'nginx\', \'wsgionly\' and \'none\'')
    }
  }

  # first init of user db for graphite

  exec { 'Initial django db creation':
    command     => 'python /usr/lib/python2.6/site-packages/graphite/manage.py syncdb --noinput',
    cwd         => '/usr/lib/python2.6/site-packages/graphite/',
    user        => $::graphite::gr_web_user,
    refreshonly => true,
    subscribe   => File['/etc/graphite-web/local_settings.py'],
    require     => File['/etc/graphite-web/local_settings.py'],
  }~>

  # change access permissions for web server

  exec { 'Chown graphite for web user':
    command     => "chown -R ${::graphite::gr_user}:${::graphite::gr_group} /var/lib/carbon/",
    cwd         => '/var/lib/',
    refreshonly => true,
    require     => $web_server_package_require,
  }

  # change access permissions for carbon-cache to align with gr_user
  # (if different from web_user)

  if $::graphite::gr_user != '' and $::graphite::gr_user != $::graphite::params::web_user {
    file {
      '/var/lib/carbon/whisper/':
        ensure  => directory,
        group   => $::graphite::gr_group,
        mode    => '0755',
        owner   => $::graphite::gr_user,
        path    => $::graphite::gr_local_data_dir,
        require => Exec['Chown graphite for web user'];

      '/var/log/carbon':
        ensure  => directory,
        group   => $::graphite::gr_group,
        mode    => '0755',
        owner   => $::graphite::gr_user,
        require => Exec['Chown graphite for web user'];
    }
  }

  # Deploy configfiles
  file {
    '/etc/graphite-web/local_settings.py':
      ensure  => file,
      content => template('graphite/opt/graphite/webapp/graphite/local_settings.py.erb'),
      group   => $::graphite::gr_web_group,
      mode    => '0644',
      owner   => $::graphite::gr_web_user,
      require => $web_server_package_require;

    '/usr/share/graphite/graphite-web.wsgi':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/graphite.wsgi.erb'),
      group   => $::graphite::gr_web_group,
      mode    => '0644',
      owner   => $::graphite::gr_web_user,
      require => $web_server_package_require;
  }

  if $::graphite::gr_remote_user_header_name {
    file { '/opt/graphite/webapp/graphite/custom_auth.py':
      ensure  => file,
      content => template('graphite/opt/graphite/webapp/graphite/custom_auth.py.erb'),
      group   => $::graphite::params::web_group,
      mode    => '0644',
      owner   => $::graphite::params::web_user,
      require => $web_server_package_require,
    }
  }

  # configure carbon engines
  if $::graphite::gr_enable_carbon_relay and $::graphite::gr_enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-cache'],
      Service['carbon-relay'],
    ]
  }
  elsif $::graphite::gr_enable_carbon_relay {
    $notify_services = [
      Service['carbon-cache'],
      Service['carbon-relay'],
    ]
  }
  elsif $::graphite::gr_enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-cache'],
    ]
  }
  else {
    $notify_services = [ Service['carbon-cache'] ]
  }

  if $::graphite::gr_enable_carbon_relay {
    file { '/etc/carbon/relay-rules.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/relay-rules.conf.erb'),
      mode    => '0644',
      notify  => $notify_services,
    }
  }

  if $::graphite::gr_enable_carbon_aggregator {
    file { '/etc/carbon/aggregation-rules.conf':
      ensure  => file,
      mode    => '0644',
      content => template('graphite/opt/graphite/conf/aggregation-rules.conf.erb'),
      notify  => $notify_services;
    }
  }

  file {
    '/etc/carbon/storage-schemas.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/storage-schemas.conf.erb'),
      mode    => '0644',
      notify  => $notify_services;

    '/etc/carbon/carbon.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/carbon.conf.erb'),
      mode    => '0644',
      notify  => $notify_services;

    '/etc/carbon/storage-aggregation.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/storage-aggregation.conf.erb'),
      mode    => '0644';

    '/etc/carbon/whitelist.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/whitelist.conf.erb'),
      mode    => '0644';

    '/etc/carbon/blacklist.conf':
      ensure  => file,
      content => template('graphite/opt/graphite/conf/blacklist.conf.erb'),
      mode    => '0644';
  }

  # startup carbon engine
  service { 'carbon-cache':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File['/etc/init.d/carbon-cache'],
  }

  file { '/etc/init.d/carbon-cache':
    ensure  => file,
    content => template("graphite/etc/init.d/carbon-cache.erb"),
    mode    => '0750',
    require => File['/etc/carbon/carbon.conf'],
  }

  if $graphite::gr_enable_carbon_relay {
    service { 'carbon-relay':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => File['/etc/init.d/carbon-relay'],
    }

    file { '/etc/init.d/carbon-relay':
      ensure  => file,
      content => template("graphite/etc/init.d/carbon-relay.erb"),
      mode    => '0750',
      require => File['/etc/carbon/carbon.conf'],
    }
  }

  if $graphite::gr_enable_carbon_aggregator {
    service {'carbon-aggregator':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => File['/etc/init.d/carbon-aggregator'],
    }

    file { '/etc/init.d/carbon-aggregator':
      ensure  => file,
      content => template("graphite/etc/init.d/carbon-aggregator.erb"),
      mode    => '0750',
      require => File['/etc/carbon/carbon.conf'],
    }
  }
}
