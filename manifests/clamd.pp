# @summary Set up clamd config and service.
#
# @param sort_options
#   For true, the options are sorted.
#
class clamav::clamd (
  Boolean $sort_options = true,
) {
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
    content => epp("${module_name}/clamav.conf.epp", {
        'config_options' => $config_options,
        'sort_options'   => $sort_options,
        'module_name'    => $module_name,
    }),
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
