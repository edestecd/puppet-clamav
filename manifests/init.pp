# init.pp
# Main class of clamav
# Declare main config here
#
# http://www.clamav.net
# http://www.clamxav.com
#

class clamav (
  $clamd             = $clamav::params::clamd,
  $freshclam         = $clamav::params::freshclam,
  $clamav_package    = $clamav::params::clamav_package,

  $clamd_package     = $clamav::params::clamd_package,
  $clamd_service     = $clamav::params::clamd_service,

  $freshclam_package = $clamav::params::freshclam_package,
  $freshclam_service = $clamav::params::freshclam_service,
) inherits clamav::params {

  validate_bool($clamd)
  validate_bool($freshclam)
  validate_string($clamav_package)

  package { 'clamav':
    name    => $clamav_package,
    ensure  => installed,
    require => Anchor['clamav::begin'],
  }

  if $clamd {
    class { 'clamav::clamd':
      clamd_package => $clamd_package,
      clamd_service => $clamd_service,
      require       => Package['clamav'],
      before        => Anchor['clamav::end'],
    }
  }

  if $freshclam {
    class { 'clamav::freshclam':
      freshclam_package => $freshclam_package,
      freshclam_service => $freshclam_service,
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
