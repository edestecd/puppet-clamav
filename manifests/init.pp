# init.pp
# Main class of clamav
# Declare main config here
#
# http://www.clamav.net
# http://www.clamxav.com
#

class clamav (
  $manage_user       = $clamav::params::manage_user,
  $manage_repo       = $clamav::params::manage_repo,
  $manage_clamd      = $clamav::params::manage_clamd,
  $manage_freshclam  = $clamav::params::manage_freshclam,
  $clamav_package    = $clamav::params::clamav_package,

  $user              = $clamav::params::user,
  $comment           = $clamav::params::comment,
  $uid               = $clamav::params::uid,
  $gid               = $clamav::params::gid,
  $home              = $clamav::params::home,
  $shell             = $clamav::params::shell,
  $group             = $clamav::params::group,
  $groups            = $clamav::params::groups,

  $clamd_package     = $clamav::params::clamd_package,
  $clamd_config      = $clamav::params::clamd_config,
  $clamd_service     = $clamav::params::clamd_service,
  $clamd_options     = $clamav::params::clamd_options,

  $freshclam_package = $clamav::params::freshclam_package,
  $freshclam_config  = $clamav::params::freshclam_config,
  $freshclam_service = $clamav::params::freshclam_service,
  $freshclam_options = $clamav::params::freshclam_options,
) inherits clamav::params {

  validate_bool($manage_user)
  validate_bool($manage_repo)
  validate_bool($manage_clamd)
  validate_bool($manage_freshclam)
  validate_string($clamav_package)

  if $manage_repo { require epel }

  if $manage_user {
    class { 'clamav::user':
      user    => $user,
      comment => $comment,
      uid     => $uid,
      gid     => $gid,
      home    => $home,
      shell   => $shell,
      group   => $group,
      groups  => $groups,
      before  => Package['clamav'],
      require => Anchor['clamav::begin'],
    }
  }

  package { 'clamav':
    ensure  => installed,
    name    => $clamav_package,
    require => Anchor['clamav::begin'],
  }

  if $manage_clamd {
    class { 'clamav::clamd':
      clamd_package => $clamd_package,
      clamd_config  => $clamd_config,
      clamd_service => $clamd_service,
      clamd_options => $clamd_options,
      require       => Package['clamav'],
      before        => Anchor['clamav::end'],
    }
  }

  if $manage_freshclam {
    class { 'clamav::freshclam':
      freshclam_package => $freshclam_package,
      freshclam_config  => $freshclam_config,
      freshclam_service => $freshclam_service,
      freshclam_options => $freshclam_options,
      require           => Package['clamav'],
      before            => Anchor['clamav::end'],
    }
  }

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'clamav::begin': }
  anchor { 'clamav::end': }

}
