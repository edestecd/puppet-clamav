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
  $groups  = $clamav::params::groups,
) inherits clamav::params {

  validate_string($comment)
  validate_absolute_path($home)
  validate_absolute_path($shell)

  if $group {
    group { 'clamav':
      ensure => present,
      name   => $group,
      gid    => $gid,
      system => true,
    }
  }

  if $user {
    user { 'clamav':
      ensure  => present,
      name    => $user,
      comment => $comment,
      uid     => $uid,
      gid     => $gid,
      groups  => $groups,
      home    => $home,
      shell   => $shell,
      system  => true,
    }
  }

}
