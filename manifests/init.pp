# init.pp
# Main class of clamav
# Declare main config here
#
# http://www.clamav.net
# http://www.clamxav.com
#

class clamav (
  Boolean $manage_user          = $clamav::params::manage_user,
  Boolean $manage_repo          = $clamav::params::manage_repo,
  Boolean $manage_clamd         = $clamav::params::manage_clamd,
  Boolean $manage_freshclam     = $clamav::params::manage_freshclam,
  Boolean $manage_clamav_milter = $clamav::params::manage_clamav_milter,
  String $clamav_package        = $clamav::params::clamav_package,
  String $clamav_version        = $clamav::params::clamav_version,

  $user                         = $clamav::params::user,
  Optional[String] $comment     = $clamav::params::comment,
  $uid                          = $clamav::params::uid,
  $gid                          = $clamav::params::gid,
  Stdlib::Absolutepath $home    = $clamav::params::home,
  Stdlib::Absolutepath $shell   = $clamav::params::shell,
  $group                        = $clamav::params::group,
  $groups                       = $clamav::params::groups,

  String $clamd_package         = $clamav::params::clamd_package,
  String $clamd_version         = $clamav::params::clamd_version,
  Stdlib::Absolutepath $clamd_config = $clamav::params::clamd_config,
  String $clamd_service         = $clamav::params::clamd_service,
  $clamd_service_ensure         = $clamav::params::clamd_service_ensure,
  Boolean $clamd_service_enable = $clamav::params::clamd_service_enable,
  Hash $clamd_options           = $clamav::params::clamd_options,

  $freshclam_package            = $clamav::params::freshclam_package,
  $freshclam_version            = $clamav::params::freshclam_version,
  Stdlib::Absolutepath $freshclam_config = $clamav::params::freshclam_config,
  $freshclam_service            = $clamav::params::freshclam_service,
  $freshclam_service_ensure     = $clamav::params::freshclam_service_ensure,
  Boolean $freshclam_service_enable = $clamav::params::freshclam_service_enable,
  Hash $freshclam_options       = $clamav::params::freshclam_options,
  Optional[Stdlib::Absolutepath] $freshclam_sysconfig = $clamav::params::freshclam_sysconfig,
  Optional[String] $freshclam_delay = $clamav::params::freshclam_delay,

  Optional[String] $clamav_milter_package = $clamav::params::clamav_milter_package,
  Optional[String] $clamav_milter_version = $clamav::params::clamav_milter_version,
  Optional[Stdlib::Absolutepath] $clamav_milter_config = $clamav::params::clamav_milter_config,
  Optional[String] $clamav_milter_service = $clamav::params::clamav_milter_service,
  $clamav_milter_service_ensure = $clamav::params::clamav_milter_service_ensure,
  Optional[Boolean] $clamav_milter_service_enable = $clamav::params::clamav_milter_service_enable,
  Optional[Hash] $clamav_milter_options = $clamav::params::clamav_milter_options,
) inherits clamav::params {

  # clamd
  $_clamd_options = merge($clamav::params::clamd_default_options, $clamd_options)

  # freshclam
  $_freshclam_options = merge($clamav::params::freshclam_default_options, $freshclam_options)

  # clamav_milter
  if $manage_clamav_milter {
    $_clamav_milter_options = merge($clamav::params::clamav_milter_default_options, $clamav_milter_options)
  }

  if $manage_repo { require 'epel' }

  if $manage_user {
    class { 'clamav::user': }
    -> Class['clamav::install']
  }

  if $manage_clamd {
    Class['clamav::install']
    -> class { 'clamav::clamd': }
  }

  if $manage_freshclam {
    Class['clamav::install']
    -> class { 'clamav::freshclam': }
  }

  if $manage_clamav_milter {
    Class['clamav::install']
    -> class { 'clamav::clamav_milter': }
  }

  class { 'clamav::install': }
}
