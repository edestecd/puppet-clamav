# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd (
  $clamd_package        = $clamav::clamd_package,
  $clamd_config         = $clamav::clamd_config,
  $clamd_service        = $clamav::clamd_service,
  $clamd_service_ensure = $clamav::clamd_service_ensure,
  $clamd_options        = $clamav::_clamd_options,
) {

  package { 'clamd':
    ensure => installed,
    name   => $clamd_package,
    before => File['clamd.conf'],
  }

  file { 'clamd.conf':
    ensure  => file,
    path    => $clamd_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/clamd.conf.${::osfamily}.erb"),
  }

  service { 'clamd':
    ensure     => $clamd_service_ensure,
    name       => $clamd_service,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [Package['clamd'], File['clamd.conf']],
  }

}
