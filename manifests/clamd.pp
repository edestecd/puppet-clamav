# @summary Set up clamd config and service.
#
# @param sort_options
#   for true, the options are sorted,
#
class clamav::clamd (
  Boolean $sort_options = true,
) {
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
    content => epp('clamav/clamav.conf.epp', {
        'options'      => $clamav::_clamd_options,
        'sort_options' => $sort_options,
    }),
  }

  if $clamav::clamd_use_socket {
    service { 'clamd_socket':
      ensure  => running,
      name    => $clamav::clamd_socket,
      enable  => true,
      require => [Package['clamd'], File['clamd.conf']],
    }

    service { 'clamd':
      ensure     => stopped,
      name       => $clamav::clamd_service,
      enable     => false,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => [Package['clamd'], File['clamd.conf']],
    }
  } else {
    service { 'clamd':
      ensure     => $clamav::clamd_service_ensure,
      name       => $clamav::clamd_service,
      enable     => $clamav::clamd_service_enable,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => [Package['clamd'], File['clamd.conf']],
    }
  }
}
