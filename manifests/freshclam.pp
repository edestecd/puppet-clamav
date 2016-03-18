# freshclam.pp
# Set up freshclam config and service.
#

class clamav::freshclam (
  $freshclam_package        = $clamav::freshclam_package,
  $freshclam_config         = $clamav::freshclam_config,
  $freshclam_service        = $clamav::freshclam_service,
  $freshclam_service_ensure = $clamav::freshclam_service_ensure,
  $freshclam_service_enable = $clamav::freshclam_service_enable,
  $freshclam_options        = $clamav::_freshclam_options,
) {

  # NOTE: In RedHat this is part of the base clamav_package
  # NOTE: In Debian this is a dependency of the base clamav_package
  if $freshclam_package {
    package { 'freshclam':
      ensure => installed,
      name   => $freshclam_package,
      before => File['freshclam.conf'],
    }
  }

  file { 'freshclam.conf':
    ensure  => file,
    path    => $freshclam_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/freshclam.conf.${::osfamily}.erb"),
  }

  # NOTE: RedHat comes with /etc/cron.daily/freshclam instead of a service
  if $freshclam_service {
    service { 'freshclam':
      ensure     => $freshclam_service_ensure,
      name       => $freshclam_service,
      enable     => $freshclam_service_enable,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['freshclam.conf'],
    }
  }

  if $freshclam_package and $freshclam_service {
    Package['freshclam'] ~> Service['freshclam']
  }

}
