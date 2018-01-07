# == Class: clamav::scan
#
# Setup a scan
#
# === Parameter:
#
# [*action_error*]
#   Shell command to run if an error occurs during scanning. Does nothing by
#   default.
#
# [*action_ok*]
#   Shell command to execute if a scan returns ok. Does nothing by default.
#
# [*action_virus*]
#   Shell command to run if a virus is detected. Does nothing by default.
#
# [*copy*]
#   Copy infected files into DIRECTORY. Directory must be writable
#   for the 'clam' user or unprivileged user running clamscan.
#
# [*enable*]
#   Should this scan be enabled? Defaults to true.
#
# [*exclude*]
#   Regular expression that, when matched, excludes a file from being scanned.
#
# [*exclude_dir*]
#   Regular expression that, when matched, excludes a directory from being
#   scanned.
#
# [*hour*]
#   Hour (in cron format) to run the scan. Defaults to a consistently random
#   hour based on the fqdn of the host. Has no impact if enable=false.
#
# [*include*]
#   Regular expression that, when matched, will include a file to be scanned.
#
# [*include_dir*]
#   Regular expression that, when matched, will include a directory to be
#   scanned.

# [*minute*]
#   Minute (in cron format) to run the scan. Defaults to a consistently random
#   minute based on the fqdn of the host. Has no impact if enable=false.
#
# [*month*]
#   Month (in cron format) to run the scan. Runs every month by default.
#
# [*monthday*]
#   Month day (in cron format) to run the scan. Runs every month day by
#   default.
#
# [*move*]
#   Move infected files into DIRECTORY. Directory must be writable
#   for the 'clam' user or unprivileged user running clamscan.
#
# [*quiet*]
#   Be quiet (only print error messages).
#
# [*recursive*]
# [*scan*]
# [*scanlog*]
# [*weekday*]
#
define clamav::scan (
  $action_error = '',
  $action_ok = '',
  $action_virus = '',
  $enable = true,
  $hour = fqdn_rand(23,$title),
  $minute = fqdn_rand(59,$title),
  $month = 'UNSET',
  $monthday = 'UNSET',
  $copy = false,
  $exclude = [ ],
  $exclude_dir = [ ],
  $flags = '',
  $include = [ ],
  $include_dir = [ ],
  $move = false,
  $quiet = true,
  $recursive = false,
  $scan = [ ],
  $scanlog = "/var/log/scan_${title}",
  $weekday = 'UNSET',
) {
    # define clamav config folder
    $clamav_path = $::operatingsystem ? {
        CentOs  => '/etc/clamd.d',
        default => '/etc/clamav',
    }
  include clamav::params
  # define the scan command
  $scancmd = "${clamav_path}/scans/${title}"
  define 
  file { "${clamav_path}/scans/":
		ensure => directory,
		owner   => $clamav::params::user,
		mode => '0700',
		require => Package['clamav'],
  }
  file { $scancmd:
    ensure  => present,
    owner   => $clamav::params::user,
    mode    => '0500',
    content => template('clamav/scan.sh.erb'),
	require => File["${clamav_path}/scans/"];
  }

  # setup our scheduled job to run this scan
  $cron_ensure = $enable ? {
    true    => 'present',
    default => 'absent',
  }
  $month_r = $month ? {
    'UNSET' => undef,
    default => $month,
  }
  $monthday_r = $monthday ? {
    'UNSET' => undef,
    default => $monthday,
  }
  $weekday_r = $weekday ? {
    'UNSET' => undef,
    default => $weekday,
  }
  cron { "clamav-scan-${title}":
    ensure   => $cron_ensure,
    command  => $scancmd,
    hour     => $hour,
    minute   => $minute,
    month    => $month_r,
    monthday => $monthday_r,
    weekday  => $weekday_r,
    require  => File[$scancmd],
  }
}
