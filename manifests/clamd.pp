# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd {

  $config_options = $clamav::_clamd_options

  # NOTE: In FreeBSD this is part of the base clamav_package
  if $clamav::clamd_package {
    package { 'clamd':
      ensure => $clamav::clamd_version,
      name   => $clamav::clamd_package,
      before => File['clamd.conf'],
    }
    $service_subscribe = [
      File['clamd.conf'],
      Package['clamd'],
    ]
  } else {
    $service_subscribe = [
      File['clamd.conf'],
    ]
  }

  file { 'clamd.conf':
    ensure  => file,
    path    => $clamav::clamd_config,
    mode    => '0644',
    owner   => 'root',
    group   => $clamav::root_group,
    content => template("${module_name}/clamav.conf.erb"),
  }

  service { 'clamd':
    ensure     => $clamav::clamd_service_ensure,
    name       => $clamav::clamd_service,
    enable     => $clamav::clamd_service_enable,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => $service_subscribe,
  }
}
