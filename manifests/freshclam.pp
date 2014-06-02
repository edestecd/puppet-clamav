# freshclam.pp
# Set up freshclam config and service.
#

class clamav::freshclam (
  $freshclam_package = $clamav::params::freshclam_package,
  $freshclam_service = $clamav::params::freshclam_service,
) inherits clamav::params {

  validate_string($freshclam_service)

  if $freshclam_package {
    package { 'freshclam':
      name   => $freshclam_package,
      ensure => installed,
      before => File['/etc/clamav/freshclam.conf'],
    }
  }

  file { '/etc/clamav/freshclam.conf':
    ensure  => file,
    mode    => 0644,
    owner   => 'root',
    group   => 'clamav',
    content => template("${module_name}/freshclam.conf.erb"),
  }

  service { 'freshclam':
    name       => $freshclam_service,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/clamav/freshclam.conf'],
  }

}
