# freshclam.pp
# Set up freshclam config and service.
#

class clamav::freshclam (
  $freshclam_package = $clamav::params::freshclam_package,
  $freshclam_config  = $clamav::params::freshclam_config,
  $freshclam_service = $clamav::params::freshclam_service,
) inherits clamav::params {

  validate_absolute_path($freshclam_config)

  # NOTE: In RedHat this is part of the base clamav_package
  if $freshclam_package {
    package { 'freshclam':
      name   => $freshclam_package,
      ensure => installed,
      before => File['freshclam.conf'],
    }
  }

  file { 'freshclam.conf':
    path    => $freshclam_config,
    ensure  => file,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/freshclam.conf.erb"),
  }

  # NOTE: RedHat comes with /etc/cron.daily/freshclam instead of a service
  if $freshclam_service {
    service { 'freshclam':
      name       => $freshclam_service,
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['freshclam.conf'],
    }
  }

}
