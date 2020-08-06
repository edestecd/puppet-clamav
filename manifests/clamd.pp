# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd {

  $config_options = $clamav::_clamd_options

  package { 'clamd':
    ensure => $clamav::clamd_version,
    name   => $clamav::clamd_package,
    before => [File['clamd.conf'], File[$clamav::clamd_default_logfile]],
  }

  file { $clamav::clamd_default_logfile:
    ensure  => file,
    mode    => '0644',
    owner   => $clamav::user,
    group   => $clamav::group,
  }

  file { 'clamd.conf':
    ensure  => file,
    path    => $clamav::clamd_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/clamav.conf.erb"),
  }

  service { 'clamd':
    ensure     => $clamav::clamd_service_ensure,
    name       => $clamav::clamd_service,
    enable     => $clamav::clamd_service_enable,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [Package['clamd'], File['clamd.conf']],
  }
}
