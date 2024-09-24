# @summary Installs clamav package
class clamav::install {
  package { 'clamav':
    ensure => $clamav::clamav_version,
    name   => $clamav::clamav_package,
  }
}
