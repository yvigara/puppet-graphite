# == Class: graphite
#
# Full Description
#
# === Parameters
#
# Document parameters here.
#
# [*ntp_servers*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
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
  $instance     = hiera('graphite_instance', 'graphite'),
  $pkg_version  = hiera('graphite_pkg_version','latest'),
  $jdk_version  = hiera('graphite_jdk_version','1.7.0_55-fcs'),
  $jars_version = hiera('graphite_jars_version','installed'),
  $repo_baseurl = hiera('graphite_repo_baseurl','http://pulp.wtf.nap/pulp/repos'),
  $apptype      = hiera('graphite_apptype', 'java'),
  $context_xml  = hiera('graphite_context_xml', 'graphite.xml'),
  $jmx_port     = hiera('graphite_jmx_port', '7095'),
  $enable       = hiera('graphite_enable',true),
  $start        = hiera('graphite_start',true),
  $user         = hiera('graphite_user', undef),
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
