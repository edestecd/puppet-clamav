# install.pp
# Installs clamav package
#

class clamav::install {

  package { 'clamav':
    ensure => $clamav::clamav_version,
    name   => $clamav::clamav_package,
  }
  if $additional_clamav_packages {
    package { $additional_clamav_packages:
      ensure => $additional_clamav_packages_version,
    }
  }
}
