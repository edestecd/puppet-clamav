# @summary Set up clamav_milter config and service.
#
# @param sort_options
#   for true, the options are sorted,
#
class clamav::clamav_milter (
  Boolean $sort_options = true,
) {
  package { 'clamav_milter':
    ensure => $clamav::clamav_milter_version,
    name   => $clamav::clamav_milter_package,
    before => File['clamav-milter.conf'],
  }

  file { 'clamav-milter.conf':
    ensure  => file,
    path    => $clamav::clamav_milter_config,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('clamav/clamav-milter.conf.epp', {
        'options'      => $clamav::_clamav_milter_options,
        'sort_options' => $sort_options,
    }),
  }

  service { 'clamav_milter':
    ensure     => $clamav::clamav_milter_service_ensure,
    name       => $clamav::clamav_milter_service,
    enable     => $clamav::clamav_milter_service_enable,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [Package['clamav_milter'], File['clamav-milter.conf']],
  }
}
