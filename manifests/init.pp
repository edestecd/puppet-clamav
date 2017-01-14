# init.pp
# Main class of clamav
# Declare main config here
#
# http://www.clamav.net
# http://www.clamxav.com
#

class clamav (
  $manage_user                  = $clamav::params::manage_user,
  $manage_repo                  = $clamav::params::manage_repo,
  $manage_clamd                 = $clamav::params::manage_clamd,
  $manage_freshclam             = $clamav::params::manage_freshclam,
  $manage_clamav_milter         = $clamav::params::manage_clamav_milter,
  $clamav_package               = $clamav::params::clamav_package,
  $clamav_version               = $clamav::params::clamav_version,

  $user                         = $clamav::params::user,
  $comment                      = $clamav::params::comment,
  $uid                          = $clamav::params::uid,
  $gid                          = $clamav::params::gid,
  $home                         = $clamav::params::home,
  $shell                        = $clamav::params::shell,
  $group                        = $clamav::params::group,
  $groups                       = $clamav::params::groups,

  $clamd_package                = $clamav::params::clamd_package,
  $clamd_version                = $clamav::params::clamd_version,
  $clamd_config                 = $clamav::params::clamd_config,
  $clamd_service                = $clamav::params::clamd_service,
  $clamd_service_ensure         = $clamav::params::clamd_service_ensure,
  $clamd_service_enable         = $clamav::params::clamd_service_enable,
  $clamd_options                = $clamav::params::clamd_options,

  $freshclam_package            = $clamav::params::freshclam_package,
  $freshclam_version            = $clamav::params::freshclam_version,
  $freshclam_config             = $clamav::params::freshclam_config,
  $freshclam_service            = $clamav::params::freshclam_service,
  $freshclam_service_ensure     = $clamav::params::freshclam_service_ensure,
  $freshclam_service_enable     = $clamav::params::freshclam_service_enable,
  $freshclam_options            = $clamav::params::freshclam_options,
  $freshclam_sysconfig          = $clamav::params::freshclam_sysconfig,
  $freshclam_delay              = $clamav::params::freshclam_delay,
  $clamav_milter_package        = $clamav::params::clamav_milter_package,
  $clamav_milter_version        = $clamav::params::clamav_milter_version,
  $clamav_milter_config         = $clamav::params::clamav_milter_config,
  $clamav_milter_service        = $clamav::params::clamav_milter_service,
  $clamav_milter_service_ensure = $clamav::params::clamav_milter_service_ensure,
  $clamav_milter_service_enable = $clamav::params::clamav_milter_service_enable,
  $clamav_milter_options        = $clamav::params::clamav_milter_options,

) inherits clamav::params {

  # Input validation
  $valid_service_statuses = '^(stopped|false|running|true)$'

  validate_bool($manage_user, $manage_repo, $manage_clamd, $manage_freshclam, $manage_clamav_milter)
  validate_string($clamav_package)
  validate_string($clamav_version)

  # user
  validate_string($comment)
  validate_absolute_path($home)
  validate_absolute_path($shell)

  # clamd
  validate_string($clamd_package)
  validate_string($clamd_version)
  validate_absolute_path($clamd_config)
  validate_string($clamd_service)
  validate_re($clamd_service_ensure, $valid_service_statuses)
  validate_bool($clamd_service_enable)
  validate_hash($clamd_options)
  $_clamd_options = merge($clamav::params::clamd_default_options, $clamd_options)

  # freshclam
  validate_absolute_path($freshclam_config)
  validate_re($freshclam_service_ensure, $valid_service_statuses)
  validate_bool($freshclam_service_enable)
  validate_hash($freshclam_options)
  $_freshclam_options = merge($clamav::params::freshclam_default_options, $freshclam_options)
  if $freshclam_sysconfig {
    validate_absolute_path($freshclam_sysconfig)
  }
  if $freshclam_delay {
    validate_string($freshclam_delay)
  }

  # clamav_milter
  validate_string($clamav_milter_package)
  validate_string($clamav_milter_version)
  validate_absolute_path($clamav_milter_config)
  validate_string($clamav_milter_service)
  validate_re($clamav_milter_service_ensure, $valid_service_statuses)
  validate_bool($clamav_milter_service_enable)
  validate_hash($clamav_milter_options)
  $_clamav_milter_options = merge($clamav::params::clamav_milter_default_options, $clamav_milter_options)

  if $manage_repo { require '::epel' }

  if $manage_user {
    Anchor['clamav::begin'] ->
    class { '::clamav::user': } ->
    Class['clamav::install']
  }

  if $manage_clamd {
    Class['clamav::install'] ->
    class { '::clamav::clamd': } ->
    Anchor['clamav::end']
  }

  if $manage_freshclam {
    Class['clamav::install'] ->
    class { '::clamav::freshclam': } ->
    Anchor['clamav::end']
  }

  if $manage_clamav_milter {
    Class['clamav::install'] ->
    class { '::clamav::clamav_milter': } ->
    Anchor['clamav::end']
  }


  anchor { 'clamav::begin': } ->
  class { '::clamav::install': } ->
  anchor { 'clamav::end': }
}
