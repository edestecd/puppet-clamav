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
  Boolean $manage_user,
  Boolean $manage_repo,
  Boolean $manage_clamd,
  Boolean $manage_freshclam,
  Boolean $manage_clamav_milter,
  String $clamav_package,
  String $clamav_version,
  String $user,
  Optional[String] $comment,
  Variant[Integer, String] $uid,
  Variant[Integer, String] $gid,
  Stdlib::Absolutepath $home,
  Stdlib::Absolutepath $shell,
  String $group,
  Optional[Array[String]] $groups,
  String $clamd_package,
  String $clamd_version,
  Stdlib::Absolutepath $clamd_config,
  String $clamd_service,
  String $clamd_service_ensure,
  Boolean $clamd_service_enable,
  Hash $clamd_options,
  Optional[String] $freshclam_package,
  Optional[String] $freshclam_version,
  Stdlib::Absolutepath $freshclam_config,
  Optional[String] $freshclam_service,
  String $freshclam_service_ensure,
  Boolean $freshclam_service_enable,
  Hash $freshclam_options,
  Optional[Stdlib::Absolutepath] $freshclam_sysconfig,
  Optional[String] $freshclam_delay,
  Optional[String] $clamav_milter_package,
  Optional[String] $clamav_milter_version,
  Optional[Stdlib::Absolutepath] $clamav_milter_config,
  Optional[String] $clamav_milter_service,
  String $clamav_milter_service_ensure,
  Boolean $clamav_milter_service_enable,
  Hash $clamav_milter_options,
  Optional[Hash] $clamd_default_options = undef,
  Optional[Hash] $freshclam_default_options = undef,
  Optional[Hash] $milter_default_options = undef,
) {
  # clamd
  $clamd_base_options = lookup('clamav::clamd_default_options', Hash, 'deep', {}, )
  $_clamd_options = merge($clamd_base_options, $clamd_options)

  # freshclam
  $freshclam_base_options = lookup('clamav::freshclam_default_options', Hash, 'deep', {}, )
  $_freshclam_options = merge($freshclam_base_options, $freshclam_options)

  # clamav-milter
  $milter_base_options = lookup('clamav::milter_default_options', Hash, 'deep', {}, )
  $_clamav_milter_options = merge($milter_base_options, $clamav_milter_options)

  if $manage_repo { require 'epel' }

  if $manage_user {
    class { 'clamav::user':
      before => Class['clamav::install'],
    }
  }

  class { 'clamav::install': }

  if $manage_clamd {
    class { 'clamav::clamd':
      require => Class['clamav::install'],
    }
  }

  if $manage_freshclam {
    class { 'clamav::freshclam':
      require => Class['clamav::install'],
    }
  }

  if $manage_clamav_milter {
    class { 'clamav::clamav_milter':
      require => Class['clamav::install'],
    }
  }
}
