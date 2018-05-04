# freshclam.pp
# Set up freshclam config and service.
#

class clamav::freshclam {

  $config_options = $clamav::_freshclam_options
  $freshclam_delay = $clamav::freshclam_delay

  # NOTE: In RedHat this is part of the base clamav_package
  # NOTE: In Debian this is a dependency of the base clamav_package
  if $clamav::freshclam_package {
    package { 'freshclam':
      ensure => $clamav::freshclam_version,
      name   => $clamav::freshclam_package,
      before => File['freshclam.conf'],
    }
  }

  $file_ensure = $clamav::freshclam_version ? {
    /^(absent|purged)$/ => 'absent',
    default             => 'file',
  }
  file { 'freshclam.conf':
    ensure  => $file_ensure,
    path    => $clamav::freshclam_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/clamav.conf.erb"),
  }

  if $clamav::freshclam_sysconfig {
    file { 'freshclam_sysconfig':
      ensure  => $file_ensure,
      path    => $clamav::freshclam_sysconfig,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/sysconfig/freshclam.erb"),
    }

    $service_subscribe = [
      File['freshclam.conf'],
      File['freshclam_sysconfig'],
    ]
  } else {
    $service_subscribe = File['freshclam.conf']
  }

  # NOTE: RedHat comes with /etc/cron.daily/freshclam instead of a service
  if $clamav::freshclam_service {
    service { 'freshclam':
      ensure     => $clamav::freshclam_service_ensure,
      name       => $clamav::freshclam_service,
      enable     => $clamav::freshclam_service_enable,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => $service_subscribe,
    }
  }

  if $clamav::freshclam_package and $clamav::freshclam_service {
    Package['freshclam'] ~> Service['freshclam']
  }
}
