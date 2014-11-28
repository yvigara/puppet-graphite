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

  # first init of user db for graphite

  exec { 'Initial django db creation':
    command     => 'python /usr/lib/python2.6/site-packages/graphite/manage.py syncdb --noinput',
    cwd         => '/usr/lib/python2.6/site-packages/graphite/',
    user        => $::graphite::gr_web_user,
    refreshonly => true,
    subscribe   => File['/etc/graphite-web/local_settings.py'],
    require     => File['/etc/graphite-web/local_settings.py'],
  }


  # Deploy configfiles

  file{'/var/lib/graphite-web/':
    ensure => directory,
    owner  => $::graphite::gr_web_user,
    group  => $::graphite::gr_web_group,
    mode   => '0755',
  }
  file {
    '/etc/graphite-web/local_settings.py':
      ensure  => file,
      mode    => '0644',
      owner   => $::graphite::gr_web_user,
      group   => $::graphite::gr_web_group,
      content => template('graphite/conf/local_settings.py.erb'),
  }
  file {
    '/usr/share/graphite/graphite-web.wsgi':
      ensure  => file,
      owner   => $::graphite::gr_web_user,
      group   => $::graphite::gr_web_group,
      mode    => '0644',
      content => template('graphite/conf/graphite.wsgi.erb'),
  }

  if $::graphite::gr_remote_user_header_name != undef {
    file {
      '/opt/graphite/webapp/graphite/custom_auth.py':
        ensure  => file,
        mode    => '0644',
        content => template('graphite/conf/custom_auth.py.erb'),
    }
  }

  # configure carbon engines
  if $::graphite::gr_enable_carbon_relay and $::graphite::gr_enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-relay'],
      Service['carbon-cache']
    ]
  }
  elsif $::graphite::gr_enable_carbon_relay {
    $notify_services = [
      Service['carbon-relay'],
      Service['carbon-cache']
    ]
  }
  elsif $::graphite::gr_enable_carbon_aggregator {
    $notify_services = [
      Service['carbon-aggregator'],
      Service['carbon-cache']
    ]
  }
  else {
    $notify_services = [ Service['carbon-cache'] ]
  }

  if $::graphite::gr_enable_carbon_relay {

    file {
      '/etc/carbon/relay-rules.conf':
        mode    => '0644',
        content => template('graphite/conf/relay-rules.conf.erb'),
        notify  => $notify_services;
    }
  }

  if $::graphite::gr_enable_carbon_aggregator {

    file {
      '/etc/carbon/aggregation-rules.conf':
      mode    => '0644',
      content => template('graphite/conf/aggregation-rules.conf.erb'),
      notify  => $notify_services;
    }
  }

  file {
    '/etc/carbon/storage-schemas.conf':
      mode    => '0644',
      content => template('graphite/conf/storage-schemas.conf.erb'),
      notify  => $notify_services;
    '/etc/carbon/carbon.conf':
      mode    => '0644',
      content => template('graphite/conf/carbon.conf.erb'),
      notify  => $notify_services;
    '/etc/carbon/storage-aggregation.conf':
      mode    => '0644',
      content => template('graphite/conf/storage-aggregation.conf.erb');
      #notify  => $notify_services;
    '/etc/carbon/whitelist.conf':
      mode    => '0644',
      content => template('graphite/conf/whitelist.conf.erb');
    '/etc/carbon/blacklist.conf':
      mode    => '0644',
      content => template('graphite/conf/blacklist.conf.erb');
  }

  # startup carbon engine

  service { 'carbon-cache':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }


  if $graphite::gr_enable_carbon_relay {
    service { 'carbon-relay':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }

  }

  if $graphite::gr_enable_carbon_aggregator {
    service {'carbon-aggregator':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }

  }
}
