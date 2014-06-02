# user.pp
# Manage clam user/group.
#

class clamav::user (
  $user    = $clamav::params::user,
  $comment = $clamav::params::comment,
  $uid     = $clamav::params::uid,
  $gid     = $clamav::params::gid,
  $home    = $clamav::params::home,
  $shell   = $clamav::params::shell,
  $group   = $clamav::params::group,
) inherits clamav::params {

  validate_string($comment)
  validate_absolute_path($home)
  validate_absolute_path($shell)

  if $group {
    group { 'clamav':
      name   => $group,
      ensure => present,
      gid    => $gid,
      system => true,
    }
  }

  if $user {
    user { 'clamav':
      name    => $user,
      ensure  => present,
      comment => $comment,
      uid     => $uid,
      gid     => $gid,
      home    => $home,
      shell   => $shell,
      system  => true,
    }
  }

}
