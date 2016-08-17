# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd {

  $config_options = $clamav::_clamd_options

  package { 'clamd':
    ensure => $clamav::clamd_version,
    name   => $clamav::clamd_package,
    before => File['clamd.conf'],
  }

  file { 'clamd.conf':
    ensure  => file,
    path    => $clamav::clamd_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/clamav.conf.erb"),
  }

  # Fix a RedHat 7 systemd bug where "is-enabled" queries fail for templated services
  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
    if $clamav::clamd_service_enable {
      $svc_file_state = 'link'
    } else {
      $svc_file_state = 'absent'
    }

    file { "/etc/systemd/system/${clamav::clamd_service}.service":
      ensure => $svc_file_state,
      backup => false,
      before => Service['clamd'],
      owner  => 'root',
      group  => 'root',
      target => '/usr/lib/systemd/system/clamd@.service',
    }
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
