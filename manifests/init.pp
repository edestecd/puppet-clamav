# init.pp
# Main class of clamav
# Declare main config here
#
# http://www.clamav.net
# http://www.clamxav.com
#

class clamav (
  $manage_user              = $clamav::params::manage_user,
  $manage_repo              = $clamav::params::manage_repo,
  $manage_clamd             = $clamav::params::manage_clamd,
  $manage_freshclam         = $clamav::params::manage_freshclam,
  $clamav_package           = $clamav::params::clamav_package,

  $user                     = $clamav::params::user,
  $comment                  = $clamav::params::comment,
  $uid                      = $clamav::params::uid,
  $gid                      = $clamav::params::gid,
  $home                     = $clamav::params::home,
  $shell                    = $clamav::params::shell,
  $group                    = $clamav::params::group,
  $groups                   = $clamav::params::groups,

  $clamd_package            = $clamav::params::clamd_package,
  $clamd_config             = $clamav::params::clamd_config,
  $clamd_service            = $clamav::params::clamd_service,
  $clamd_service_ensure     = $clamav::params::clamd_service_ensure,
  $clamd_service_enable     = $clamav::params::clamd_service_enable,
  $clamd_options            = $clamav::params::clamd_options,

  $freshclam_package        = $clamav::params::freshclam_package,
  $freshclam_config         = $clamav::params::freshclam_config,
  $freshclam_service        = $clamav::params::freshclam_service,
  $freshclam_service_ensure = $clamav::params::freshclam_service_ensure,
  $freshclam_service_enable = $clamav::params::freshclam_service_enable,
  $freshclam_options        = $clamav::params::freshclam_options,
) inherits clamav::params {

  # Input validation
  $valid_service_statuses = '^(stopped|false|running|true)$'

  validate_bool($manage_user, $manage_repo, $manage_clamd, $manage_freshclam)
  validate_string($clamav_package)

  # user
  validate_string($comment)
  validate_absolute_path($home)
  validate_absolute_path($shell)

  # clamd
  validate_string($clamd_package)
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

  anchor { 'clamav::begin': } ->
  class { '::clamav::install': } ->
  anchor { 'clamav::end': }
}
