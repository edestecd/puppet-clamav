# @summary Manage clam user/group.
class clamav::user {
  if !empty($clamav::group) {
    group { 'clamav':
      ensure => present,
      name   => $clamav::group,
      gid    => $clamav::gid,
      system => true,
    }
  }

  if !empty($clamav::user) {
    user { 'clamav':
      ensure  => present,
      name    => $clamav::user,
      comment => $clamav::comment,
      uid     => $clamav::uid,
      gid     => $clamav::gid,
      groups  => $clamav::groups,
      home    => $clamav::home,
      shell   => $clamav::shell,
      system  => true,
    }
  }
}
