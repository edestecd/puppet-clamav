# install.pp
# Installs clamav package
#

class clamav::install (
  $clamav_package = $::clamav::clamav_package,
){

  package { 'clamav':
    ensure => installed,
    name   => $clamav_package,
  }

}
