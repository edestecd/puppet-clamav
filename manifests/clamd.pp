# clamd.pp
# Set up clamd config and service.
#

class clamav::clamd (
  $clamd_package = $clamav::params::clamd_package,
  $clamd_service = $clamav::params::clamd_service,
) inherits clamav::params {

  validate_string($clamd_service)

  if $clamd_package {
    package { 'clamd':
      name   => $clamd_package,
      ensure => installed,
      before => File['/etc/clamav/clamd.conf'],
    }
  }

  file { '/etc/clamav/clamd.conf':
    ensure  => file,
    mode    => 0644,
    owner   => 'root',
    group   => 'clamav',
    content => template("${module_name}/clamd.conf.erb"),
  }

  service { 'clamd':
    name       => $clamd_service,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/clamav/clamd.conf'],
  }

}
