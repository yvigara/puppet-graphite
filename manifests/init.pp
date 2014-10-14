# == Class: graphite
#
# This class installs and configures graphite/carbon/whisper.
#
# === Parameters
#
# [*group*]
#   The group of the user (see user) who runs graphite.
#   Default is empty.
# [*user*]
#   The user who runs graphite. If this is empty carbon runs as the user that
#   invokes it.
#   Default is empty.
# [*max_cache_size*]
#   Limit the size of the cache to avoid swapping or becoming CPU bound. Use
#   the value "inf" (infinity) for an unlimited cache size.
#   Default is inf.
# [*max_updates_per_second*]
#   Limits the number of whisper update_many() calls per second, which
#   effectively means the number of write requests sent to the disk.
#   Default is 500.
# [*max_creates_per_minute*]
#   Softly limits the number of whisper files that get created each minute.
#   Default is 50.
# [*carbon_metric_interval*]
#   The interval (in seconds) between sending internal performance metrics.
#   Default is 60; 0 to disable instrumentation
# [*line_receiver_interface*]
#   Interface the line receiver listens.
#   Default is 0.0.0.0
# [*line_receiver_port*]
#   Port of line receiver.
#   Default is 2003
# [*enable_udp_listener*]
#   Set this to True to enable the UDP listener.
#   Default is False.
# [*udp_receiver_interface*]
#   Its clear, isnt it?
#   Default is 0.0.0.0
# [*udp_receiver_port*]
#   Self explaining.
#   Default is 2003
# [*pickle_receiver_interface*]
#   Pickle is a special receiver who handle tuples of data.
#   Default is 0.0.0.0
# [*pickle_receiver_port*]
#   Self explaining.
#   Default is 2004
# [*use_insecure_unpickler*]
#   Set this to True to revert to the old-fashioned insecure unpickler.
#   Default is False.
#[*use_whitelist*]
#   Set this to True to allow for using whitelists and blacklists.
#   Default is False.
# [*cache_query_interface*]
#   Interface to send cache queries to.
#   Default is 0.0.0.0
# [*cache_query_port*]
#   Self explaining.
#   Default is 7002.
# [*timezone*]
#   Timezone for graphite to be used.
#   Default is GMT.
# [*storage_schemas*]
#  The storage schemas.
#  Default is
#  [{name => "default", pattern => ".*", retentions => "1s:30m,1m:1d,5m:2y"}]
# [*storage_aggregation_rules*]
#   rule set for storage aggregation ... items get sorted, first match wins
#   pattern = <regex>
#   factor = <float between 0 and 1>
#   method = <average|sum|last|max|min>
#   Default is :
#   {
#     '00_min' => {
#       pattern => '\.min$',
#       factor => '0.1',
#       method => 'min'
#     },
#     '01_max' => {
#       pattern => '\.max$',
#       factor => '0.1',
#       method => 'max' },
#     '01_sum' => {
#       pattern => '\.count$',
#       factor => '0.1',
#       method => 'sum'
#     },
#     '99_default_avg' => {
#       pattern => '.*',
#       factor => '0.5',
#       method => 'average'
#     }
#   }
#   (matches the exammple configuration from graphite 0.9.12)
# [*web_server*]
#   The web server to use.
#   Valid values are 'apache', 'nginx', 'wsgionly' and 'none'. 'nginx' is only
#   supported on Debian-like systems.
#   'wsgionly' will omit apache and nginx, allowing you to run your own
#   webserver and communicate via wsgi to the unix socket. Handy for servers
#   with multiple vhosts/purposes etc.
#   'none' will do the same as wsgionly but skips gunicorn also, omitting
#   apache and gunicorn/nginx. All other webserver settings below are
#   irrelevant if this is 'wsgionly' or 'none'.
#   Default is 'apache'.
# [*web_servername*]
#   Virtualhostname of Graphite webgui.
#   Default is FQDN.
# [*web_group*]
#   Group name to chgrp the files that will served by webserver.  Use only with web_server => 'wsgionly' or 'none'.
# [*web_user*]
#   Username to chown the files that will served by webserver.  Use only with web_server => 'wsgionly' or 'none'.
# [*web_cors_allow_from_all*]
#   Include CORS Headers for all hosts (*) in web server config
#   Default is false.
# [*apache_port*]
#   The port to run graphite web server on.
#   Default is 80.
# [*apache_port_https*]
#   The port to run SSL web server on if you have an existing web server on
#   the default port 443.
#   Default is 443.
# [*apache_24*]
#   Boolean to enable configuration parts for Apache 2.4 instead of 2.2
#   Default is false. (use Apache 2.2 config)
# [*django_1_4_or_less*]
#   Set to true to use old Django settings style.
#   Default is false.
# [*django_db_xxx*]
#   Django database settings. (engine|name|user|password|host|port)
#   Default is a local sqlite3 db.
# [*enable_carbon_relay*]
#   Enable carbon relay.
#   Default is false.
# [*relay_line_interface*]
#   Default is '0.0.0.0'
# [*relay_line_port*]
#   Default is 2013.
# [*relay_pickle_interface*]
#   Default is '0.0.0.0'
# [*relay_pickle_port*]
#   Default is 2014.
# [*relay_method*]
#   Default is 'rules'
# [*relay_replication_factor*]
#   add redundancy by replicating every datapoint to more than one machine.
#   Default is 1.
# [*relay_destinations*]
#   Array of backend carbons for relay.
#   Default  is [ '127.0.0.1:2004' ]
# [*relay_max_queue_size*]
#   Default is 10000.
# [*relay_use_flow_control*]
#   Default is 'True'
# [*relay_rules*]
#   Relay rule set.
#   Default is
#   {
#   all       => { pattern      => '.*',
#                  destinations => [ '127.0.0.1:2004' ] },
#   'default' => { 'default'    => true,
#                  destinations => [ '127.0.0.1:2004:a' ] },
#   }
# [*enable_carbon_aggregator*]
#   Enable the carbon aggregator daemon
#   Default is false.
# [*aggregator_line_interface*]
#   Default is '0.0.0.0'
# [*aggregator_line_port*]
#   Default is 2023.
# [*aggregator_pickle_interface*]
#   Default is '0.0.0.0'
# [*aggregator_pickle_port*]
#   Default is 2024.
# [*aggregator_forward_all*]
#   Default is 'True'
# [*aggregator_destinations*]
#   Array of backend carbons
#   Default is [ '127.0.0.1:2004' ]
# [*aggregator_replication_factor*]
#   add redundancy by replicating every datapoint to more than one machine.
#   Default is 1.
# [*aggregator_max_queue_size*]
#   Default is 10000
# [*aggregator_use_flow_control*]
#   Default is 'True'
# [*aggregator_max_intervals*]
#   Default is 5
# [*aggregator_rules*]
#   Array of aggregation rules, as configuration file lines
#   Default is {
#    'carbon-class-mem' =>
#       carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
#    'carbon-all-mem' =>
#       'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
#    }
# [*amqp_enable*]
#   Set this to 'True' to enable the AMQP.
#   Default is 'False'.
# [*amqp_verbose*]
#   Set this to 'True' to enable. Verbose means a line will be logged for
#   every metric received useful for testing.
#   Default is 'False'.
# [*amqp_host*]
#   Self explaining.
#   Default is localhost.
# [*amqp_port*]
#   Self explaining.
#   Default is 5672.
# [*amqp_vhost*]
#   Virtual host of AMQP. Set the name without the slash, eg. 'graphite'.
#   Default is '/'.
# [*amqp_user*]
#   Self explaining.
#   Default is guest.
# [*amqp_password*]
#   Self explaining.
#   Default is guest.
# [*amqp_exchange*]
#   Self explaining.
#   Default is graphite.
# [*amqp_metric_name_in_body*]
#   Self explaining.
#   Default is 'False'.
# [*memcache_hosts*]
#   Array of memcache hosts. e.g.: ['127.0.0.1:11211', '10.10.10.1:11211']
#   Defalut is undef
# [*secret_key*]
#   Secret used as salt for things like hashes, cookies, sessions etc.
#   Has to be the same on all nodes of a graphite cluster.
#   Default is UNSAFE_DEFAULT (CHANGE IT!)
# [*cluster_enable*]
#   en/dis-able cluster configuration.   Default: false
# [*cluster_servers*]
#   list of IP:port tuples for the servers in the cluster.  Default: "[]"
# [*cluster_fetch_timeout*]
#    Timeout to fetch series data.   Default = 6
# [*cluster_find_timeout*]
#    Timeout for metric find requests.   Default = 2.5
# [*cluster_retry_delay*]
#    Time before retrying a failed remote webapp.  Default = 60
# [*cluster_cache_duration*]
#    Time to cache remote metric find results.  Default = 300
# [*nginx_htpasswd*]
#   The user and salted SHA-1 (SSHA) password for Nginx authentication.
#   If set, Nginx will be configured to use HTTP Basic authentication with the
#   given user & password.
#   Default is undefined
# [*manage_ca_certificate*]
#   Used to determine to install ca-certificate or not. default = true
# [*use_ldap*]
#   Turn ldap authentication on/off. Default = false
# [*ldap_uri*]
#   Set ldap uri.  Default = ''
# [*ldap_search_base*]
#   Set the ldap search base.  Default = ''
# [*ldap_base_user*]
#   Set ldap base user.  Default = ''
# [*ldap_base_pass*]
#   Set ldap password.  Default = ''
# [*ldap_user_query*]
#   Set ldap user query.  Default = '(username=%s)'
# [*use_remote_user_auth*]
#   Allow use of REMOTE_USER env variable within Django/Graphite.
#   Default is 'False' (String)
# [*remote_user_header_name*]
#   Allows the use of a custom HTTP header, instead of the REMOTE_USER env
#   variable (mainly for nginx use) to tell Graphite a user is authenticated.
#   Useful when using an external auth handler with X-Accel-Redirect etc.
#   Example value - HTTP_X_REMOTE_USER

# === Examples
#
# class {'graphite':
#   max_cache_size      => 256,
#   enable_udp_listener => True,
#   timezone            => 'Europe/Berlin'
# }
#
#
# === Authors
#
# webOps <webops@net-a-porter.com>
#
# === Copyright
#
# Copyright 2013, Net-a-Porter Inc
#
class graphite (
  $group                     = 'graphite',
  $user                      = 'graphite',
  $max_cache_size            = inf,
  $max_updates_per_second    = 500,
  $max_creates_per_minute    = 50,
  $carbon_metric_interval    = 60,
  $line_receiver_interface   = '0.0.0.0',
  $line_receiver_port        = 2003,
  $enable_udp_listener       = 'False',
  $udp_receiver_interface    = '0.0.0.0',
  $udp_receiver_port         = 2003,
  $pickle_receiver_interface = '0.0.0.0',
  $pickle_receiver_port      = 2004,
  $use_insecure_unpickler    = 'False',
  $use_whitelist             = 'False',
  $cache_query_interface     = '0.0.0.0',
  $cache_query_port          = 7002,
  $timezone                  = 'GMT',
  $storage_schemas           = [
    {
      name       => 'carbon',
      pattern    => '^carbon\.',
      retentions => '1m:90d'
    },
    {
      name       => 'default',
      pattern    => '.*',
      retentions => '1s:30m,1m:1d,5m:2y'
    }
  ],
  $storage_aggregation_rules  = {
    '00_min' => {
      pattern => '\.min$',
      factor => '0.1',
      method => 'min'
    },
    '01_max' => {
      pattern => '\.max$',
      factor => '0.1',
      method => 'max'
    },
    '02_sum' => {
      pattern => '\.count$',
      factor => '0.1',
      method => 'sum'
    },
    '99_default_avg' => {
      pattern => '.*',
      factor => '0.5',
      method => 'average'
    }
  },
  $web_servername            = $::fqdn,
  $web_group                 = 'apache',
  $web_user                  = 'apache',
  $web_cors_allow_from_all   = false,
  $django_1_4_or_less        = false,
  $django_db_engine          = 'django.db.backends.sqlite3',
  $django_db_name            = '/var/lib/graphite-web/graphite.db',
  $django_db_user            = '',
  $django_db_password        = '',
  $django_db_host            = '',
  $django_db_port            = '',
  $enable_carbon_relay       = false,
  $relay_line_interface      = '0.0.0.0',
  $relay_line_port           = 2013,
  $relay_pickle_interface    = '0.0.0.0',
  $relay_pickle_port         = 2014,
  $relay_method              = 'rules',
  $relay_replication_factor  = 1,
  $relay_destinations        = [ '127.0.0.1:2004' ],
  $relay_max_queue_size      = 10000,
  $relay_use_flow_control    = 'True',
  $relay_rules               = {
    all => {
      pattern      => '.*',
      destinations => [ '127.0.0.1:2004' ]
    },
    'default' => {
      'default'    => true,
      destinations => [ '127.0.0.1:2004:a' ]
    },
  },
  $enable_carbon_aggregator  = false,
  $aggregator_line_interface = '0.0.0.0',
  $aggregator_line_port      = 2023,
  $aggregator_pickle_interface = '0.0.0.0',
  $aggregator_pickle_port    = 2024,
  $aggregator_forward_all    = 'True',
  $aggregator_destinations   = [ '127.0.0.1:2004' ],
  $aggregator_replication_factor = 1,
  $aggregator_max_queue_size = 10000,
  $aggregator_use_flow_control = 'True',
  $aggregator_max_intervals  = 5,
  $aggregator_rules          = {
    'carbon-class-mem' => 'carbon.all.<class>.memUsage (60) = sum carbon.<class>.*.memUsage',
    'carbon-all-mem'   => 'carbon.all.memUsage (60) = sum carbon.*.*.memUsage',
    },
  $amqp_enable               = 'False',
  $amqp_verbose              = 'False',
  $amqp_host                 = 'localhost',
  $amqp_port                 = 5672,
  $amqp_vhost                = '/',
  $amqp_user                 = 'guest',
  $amqp_password             = 'guest',
  $amqp_exchange             = 'graphite',
  $amqp_metric_name_in_body  = 'False',
  $memcache_hosts            = undef,
  $secret_key                   = 'UNSAFE_DEFAULT',
  $cluster_enable            = false,
  $cluster_servers           = '[]',
  $cluster_fetch_timeout     = 6,
  $cluster_find_timeout      = 2.5,
  $cluster_retry_delay       = 60,
  $cluster_cache_duration    = 300,
  $nginx_htpasswd               = undef,
  $manage_ca_certificate        = true,
  $use_ldap                  = false,
  $ldap_uri                  = '',
  $ldap_search_base          = '',
  $ldap_base_user            = '',
  $ldap_base_pass            = '',
  $ldap_user_query           = '(username=%s)',
  $use_remote_user_auth      = 'False',
  $remote_user_header_name   = undef
) {

  class{'graphite::repo': stage => 'first' }
  class{'graphite::users': stage => 'first' }

  anchor{'graphite::begin':}      ~>
  class{'graphite::package': }    ~>
  class{'graphite::config': }     ~>
  class{'graphite::service': }    ~>
  class{'graphite::monitoring': } ~>
  anchor{'graphite::end':}

}
