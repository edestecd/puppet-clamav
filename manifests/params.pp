# params.pp
# Set up ClamAV parameters defaults etc.
#
# @Todo: add osx support with ClamXav
#

class clamav::params {

  #### init vars ####
  $clamd     = false
  $freshclam = false


  if ($::osfamily == 'RedHat') and ($::operatingsystemrelease >= 6.0) {
    #### init vars ####
    $clamav_package    = 'clamav'

    #### clamd vars ####
    $clamd_service     = 'clamd'

    #### freshclam vars ####
    $freshclam_service = 'freshclam'
  } elsif ($::osfamily == 'Debian') and ($::operatingsystemrelease >= 12.0) {
    #### init vars ####
    $clamav_package    = 'clamav'

    #### clamd vars ####
    $clamd_package     = 'clamav-daemon'
    $clamd_service     = 'clamav-daemon'

    #### freshclam vars ####
    $freshclam_package = 'clamav-freshclam'
    $freshclam_service = 'clamav-freshclam'
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

}
