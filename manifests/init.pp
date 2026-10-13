# @summary Manage ClamAV installation, configuration, user, and services.
#
# @param manage_user Whether to manage the ClamAV system user.
# @param manage_repo Whether to manage the EPEL repository.
# @param manage_clamd Whether to manage clamd.
# @param manage_freshclam Whether to manage freshclam.
# @param manage_clamav_milter Whether to manage clamav-milter.
# @param clamav_package Name of the main ClamAV package.
# @param clamav_version Desired version of the main ClamAV package.
# @param user ClamAV system username.
# @param comment Optional description of the ClamAV system user.
# @param uid UID of the ClamAV system user.
# @param gid GID of the ClamAV system user.
# @param home Home directory of the ClamAV system user.
# @param shell Login shell of the ClamAV system user.
# @param group Primary group of the ClamAV system user.
# @param groups Additional groups for the ClamAV system user.
# @param clamd_package Name of the clamd package.
# @param clamd_version Desired version of the clamd package.
# @param clamd_config Absolute path to the clamd configuration file.
# @param clamd_service Name of the clamd service.
# @param clamd_service_ensure Desired clamd service state.
# @param clamd_service_enable Whether to enable clamd at boot.
# @param clamd_options Custom clamd configuration options.
# @param freshclam_package Name of the freshclam package, if applicable.
# @param freshclam_version Desired freshclam package version, if applicable.
# @param freshclam_config Absolute path to the freshclam configuration file.
# @param freshclam_service Name of the freshclam service, if applicable.
# @param freshclam_service_ensure Desired freshclam service state.
# @param freshclam_service_enable Whether to enable freshclam at boot.
# @param freshclam_options Custom freshclam configuration options.
# @param freshclam_sysconfig Optional path to the freshclam sysconfig file.
# @param freshclam_delay Optional delay before freshclam updates.
# @param clamav_milter_package Name of the milter package, if applicable.
# @param clamav_milter_version Desired milter package version, if applicable.
# @param clamav_milter_config Optional path to the milter configuration file.
# @param clamav_milter_service Name of the milter service, if applicable.
# @param clamav_milter_service_ensure Desired milter service state.
# @param clamav_milter_service_enable Whether to enable the milter at boot.
# @param clamav_milter_options Custom milter configuration options.
# @param clamd_default_options Optional base configuration for clamd.
# @param freshclam_default_options Optional base configuration for freshclam.
# @param milter_default_options Optional base configuration for clamav-milter.
class clamav (
  Boolean $manage_user          = $clamav::params::manage_user,
  Boolean $manage_repo          = $clamav::params::manage_repo,
  Boolean $manage_clamd         = $clamav::params::manage_clamd,
  Boolean $manage_freshclam     = $clamav::params::manage_freshclam,
  Boolean $manage_clamav_milter = $clamav::params::manage_clamav_milter,

  String $clamav_package = $clamav::params::clamav_package,
  String $clamav_version = $clamav::params::clamav_version,

  String $user = $clamav::params::user,
  Optional[String] $comment = $clamav::params::comment,
  Variant[Integer, String] $uid = $clamav::params::uid,
  Variant[Integer, String] $gid = $clamav::params::gid,
  Stdlib::Absolutepath $home = $clamav::params::home,
  Stdlib::Absolutepath $shell = $clamav::params::shell,
  String $group = $clamav::params::group,
  Optional[Array[String]] $groups = $clamav::params::groups,

  String $clamd_package = $clamav::params::clamd_package,
  String $clamd_version = $clamav::params::clamd_version,
  Stdlib::Absolutepath $clamd_config = $clamav::params::clamd_config,
  String $clamd_service = $clamav::params::clamd_service,
  String $clamd_service_ensure = $clamav::params::clamd_service_ensure,
  Boolean $clamd_service_enable = $clamav::params::clamd_service_enable,
  Hash $clamd_options = $clamav::params::clamd_options,

  Optional[String] $freshclam_package = $clamav::params::freshclam_package,
  Optional[String] $freshclam_version = $clamav::params::freshclam_version,
  Stdlib::Absolutepath $freshclam_config = $clamav::params::freshclam_config,
  Optional[String] $freshclam_service = $clamav::params::freshclam_service,
  String $freshclam_service_ensure = $clamav::params::freshclam_service_ensure,
  Boolean $freshclam_service_enable = $clamav::params::freshclam_service_enable,
  Hash $freshclam_options = $clamav::params::freshclam_options,
  Optional[Stdlib::Absolutepath] $freshclam_sysconfig = $clamav::params::freshclam_sysconfig,
  Optional[String] $freshclam_delay = $clamav::params::freshclam_delay,

  Optional[String] $clamav_milter_package = $clamav::params::clamav_milter_package,
  Optional[String] $clamav_milter_version = $clamav::params::clamav_milter_version,
  Optional[Stdlib::Absolutepath] $clamav_milter_config = $clamav::params::clamav_milter_config,
  Optional[String] $clamav_milter_service = $clamav::params::clamav_milter_service,
  String $clamav_milter_service_ensure = $clamav::params::clamav_milter_service_ensure,
  Boolean $clamav_milter_service_enable = $clamav::params::clamav_milter_service_enable,
  Hash $clamav_milter_options = $clamav::params::clamav_milter_options,

  Optional[Hash] $clamd_default_options = undef,
  Optional[Hash] $freshclam_default_options = undef,
  Optional[Hash] $milter_default_options = undef,
) inherits clamav::params {
  # clamd
  if $clamd_default_options {
    $_clamd_options = merge($clamd_default_options, $clamd_options)
  } else {
    $_clamd_options = merge($clamav::params::clamd_default_options, $clamd_options)
  }

  # freshclam
  if $freshclam_default_options {
    $_freshclam_options = merge($freshclam_default_options, $freshclam_options)
  } else {
    $_freshclam_options = merge($clamav::params::freshclam_default_options, $freshclam_options)
  }

  # clamav_milter
  if $milter_default_options {
    $_clamav_milter_options = merge($milter_default_options, $clamav_milter_options)
  } else {
    $_clamav_milter_options = merge($clamav::params::clamav_milter_default_options, $clamav_milter_options)
  }

  if $manage_repo { require 'epel' }

  if $manage_user {
    Anchor['clamav::begin']
    -> class { 'clamav::user': }
    -> Class['clamav::install']
  }

  if $manage_clamd {
    Class['clamav::install']
    -> class { 'clamav::clamd': }
    -> Anchor['clamav::end']
  }

  if $manage_freshclam {
    Class['clamav::install']
    -> class { 'clamav::freshclam': }
    -> Anchor['clamav::end']
  }

  if $manage_clamav_milter {
    Class['clamav::install']
    -> class { 'clamav::clamav_milter': }
    -> Anchor['clamav::end']
  }

  anchor { 'clamav::begin': }
  -> class { 'clamav::install': }
  -> anchor { 'clamav::end': }
}
