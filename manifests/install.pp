# install.pp
# Installs clamav package
#

class clamav::install (
  $clamav_package = $::clamav::clamav_package,
  $clamav_version = $::clamav::clamav_version,
){

  package { 'clamav':
    ensure => $clamav_version,
    name   => $clamav_package,
  }

}
