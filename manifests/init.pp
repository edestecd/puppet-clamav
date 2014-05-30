# init.pp
# Main class of clamav
# Declare main config here
#

class clamav (
  $clamd             = $clamav::params::clamd,
  $freshclam         = $clamav::params::freshclam,
  $clamav_package    = $clamav::params::clamav_package,

  $clamd_package     = $clamav::params::clamd_package,
  $freshclam_package = $clamav::params::freshclam_package,
) inherits clamav::params {

  validate_bool($clamd)
  validate_bool($freshclam)
  validate_string($clamav_package)

  package { $clamav_package:
    ensure => installed,
  }

}
