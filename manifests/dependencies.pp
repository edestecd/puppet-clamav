class clamav::dependencies {
  package {'clamav-filesystem':
    ensure => $clamav::clamav_version,
    name   => 'clamav-filesystem',
  }
  package {'clamav-data':
    ensure => $clamav::clamav_version,
    name   => 'clamav-data',
  }
  package {'clamav-lib':
    ensure => $clamav::clamav_version,
    name   => 'clamav-lib',
  }
}
