# == class: graphite::package

class graphite::package {

  if $graphite::apptype == 'java' {
    class { 'tomcat':
      jdk_version => $graphite::jdk_version,
    }
    tomcat::catalinabase { "${graphite::instance}":
      instance    => $graphite::instance,
      serverxml   => "${module_name}/server.xml.erb",
      context_xml => $graphite::context_xml,
      jmx_port    => "${graphite::jmx_port}",
    }
    package { 'nap-tomcat7-jars': ensure => $graphite::jars_version }
  }

  package{'graphite':
    ensure => $graphite::pkg_version ,
    notify => Service["${graphite::instance}"],
  }


}

