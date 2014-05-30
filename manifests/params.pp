# params.pp
# Set up ClamAV parameters defaults etc.
#

class clamav::params {

  #### init vars ####
  $clamd     = false
  $freshclam = false


  if ($::osfamily == 'RedHat') and ($::operatingsystemrelease >= 6.0) {
    $clamav_package     = 'clamav'
  } elsif ($::osfamily == 'Debian') and ($::operatingsystemrelease >= 12.0) {
    $clamav_package     = 'clamav'

    $clamd_package      = 'clamav-daemon'
    $freshclam_package  = 'clamav-freshclam'
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

}
