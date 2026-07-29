# @summary Set up freshclam config and service.
#
# @param config_owner
#   owner of the freshclam config file
# @param config_group
#   group that owns the freshclam config file
# @param config_mode
#   mode of the freshclam config file
# @param sort_options
#   for true, the options are sorted,
#
class clamav::freshclam (
  String  $config_owner = 'root',
  String  $config_group = 'root',
  String  $config_mode  = '0644',
  Boolean $sort_options = true,
) {
  # NOTE: In RedHat this is part of the base clamav_package
  # NOTE: In Debian this is a dependency of the base clamav_package
  if $clamav::freshclam_package {
    package { 'freshclam':
      ensure => $clamav::freshclam_version,
      name   => $clamav::freshclam_package,
      before => File['freshclam.conf'],
    }
  }

  # Ubuntu 20.04 does not reliably create the runtime directory before
  # freshclam attempts to write its PID file.
  if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '20.04' {
    file { '/var/run/clamav':
      ensure  => directory,
      owner   => $clamav::user,
      group   => $clamav::group,
      mode    => '0755',
      require => Package['freshclam'],
      before  => File['freshclam.conf'],
    }
  }

  file { 'freshclam.conf':
    ensure  => file,
    path    => $clamav::freshclam_config,
    mode    => $config_mode,
    owner   => $config_owner,
    group   => $config_group,
    content => epp('clamav/freshclam.conf.epp', {
        'options'      => $clamav::_freshclam_options,
        'sort_options' => $sort_options,
    }),
  }

  if $clamav::freshclam_sysconfig {
    file { 'freshclam_sysconfig':
      ensure  => file,
      path    => $clamav::freshclam_sysconfig,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => epp('clamav/sysconfig/freshclam.epp', {
          'freshclam_delay' => $clamav::freshclam_delay,
      }),
    }

    $service_subscribe = [
      File['freshclam.conf'],
      File['freshclam_sysconfig'],
    ]
  } else {
    $service_subscribe = File['freshclam.conf']
  }

  # NOTE: RedHat <8 comes with /etc/cron.daily/freshclam instead of a service
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
