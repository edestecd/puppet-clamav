# install.pp
# Installs clamav package
#

class clamav::install {
  require ::clamav::dependencies

  package { 'clamav':
    ensure => $clamav::clamav_version,
    name   => $clamav::clamav_package,
  }
}
