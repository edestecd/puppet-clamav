# install.pp
# Installs clamav package
#

class clamav::install {

  package { 'clamav':
    ensure => $clamav::clamav_version,
    name   => $clamav::clamav_package,
  }
  if $clamav::additional_clamav_packages {
    package { $clamav::additional_clamav_packages:
      ensure => $clamav::additional_clamav_packages_version,
    }
  }
}
