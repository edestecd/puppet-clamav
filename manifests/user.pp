# user.pp
# Manage clam user/group.
#

class clamav::user (
  $user    = $clamav::user,
  $comment = $clamav::comment,
  $uid     = $clamav::uid,
  $gid     = $clamav::gid,
  $home    = $clamav::home,
  $shell   = $clamav::shell,
  $group   = $clamav::group,
  $groups  = $clamav::groups,
) {

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
