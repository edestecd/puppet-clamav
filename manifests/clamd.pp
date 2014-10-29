# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd (
  $clamd_package = $clamav::params::clamd_package,
  $clamd_config  = $clamav::params::clamd_config,
  $clamd_service = $clamav::params::clamd_service,
  $clamd_options = $clamav::params::clamd_options,
) inherits clamav::params {

  validate_string($clamd_package)
  validate_absolute_path($clamd_config)
  validate_string($clamd_service)
  validate_hash($clamd_options)

  $config_options = merge($clamav::params::clamd_default_options, $clamd_options)

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
    ensure     => running,
    name       => $clamd_service,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['clamd.conf'],
  }

}
