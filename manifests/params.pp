# params.pp
# Set up ClamAV parameters defaults etc.
#
# @Todo: add osx support with ClamXav
#

class clamav::params {

  # ### init vars ####
  $manage_user                  = false
  $manage_clamd                 = false
  $manage_clamav_milter         = false
  $manage_freshclam             = false
  $clamd_service_ensure         = 'running'
  $clamd_service_enable         = true
  $freshclam_service_ensure     = 'running'
  $freshclam_service_enable     = true
  $freshclam_initial_run        = true
  $clamav_milter_service_ensure = 'running'
  $clamav_milter_service_enable = true

  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    # ### init vars ####
    $manage_repo    = true
    $clamav_package = 'clamav'
    $clamav_version = 'installed'

    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
      # ### user vars ####
      $user              = 'clamscan'
      $comment           = 'Clamav scanner user'
      $uid               = 496
      $gid               = 496
      $home              = '/'
      $shell             = '/sbin/nologin'
      $group             = 'clamscan'
      $groups            = undef

      # ### clamd vars ####
      $clamd_package     = 'clamav-scanner-systemd'
      $clamd_version     = 'installed'
      $clamd_config      = '/etc/clamd.d/scan.conf'
      $clamd_service     = 'clamd@scan'
      $clamd_options     = {}

      # ### Default values OS specific ####
      $clamd_default_localsocket = '/var/run/clamd.scan/clamd.sock'
      $clamd_default_logfile     = undef # '/var/log/clamd.scan'
      $clamd_default_pidfile     = '/var/run/clamd.scan/clamd.pid'
      $freshclam_default_databaseowner = 'clamupdate'
      $freshclam_default_updatelogfile = undef # '/var/log/freshclam.log'

      # ### freshclam vars ####
      $freshclam_package = 'clamav-update'
      $freshclam_version = 'installed'
      $freshclam_config  = '/etc/freshclam.conf'
      $freshclam_options = {}
      $freshclam_sysconfig = '/etc/sysconfig/freshclam'
      $freshclam_delay     = undef

      # ### RHEL8/Centos8 actually do have a service
      if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
        $freshclam_service = 'clamav-freshclam'
      } else {
        $freshclam_service = undef
      }

      # ### clamav_milter vars ####
      $clamav_milter_package     = 'clamav-milter-systemd'
      $clamav_milter_version     = 'installed'
      $clamav_milter_config      = '/etc/mail/clamav-milter.conf'
      $clamav_milter_service     = 'clamav-milter'
      $clamav_milter_options     = {}
      $clamav_milter_default_options = {
        'User'                     => 'clamilt',
        'MilterSocket'             => 'inet:8890@localhost',
        'ClamdSocket'              => 'tcp:127.0.0.1',
        'LogSyslog'                => 'yes',
      }

    } else {
      # ### user vars ####
      $user              = 'clam'
      $comment           = 'Clam Anti Virus Checker'
      $uid               = 496
      $gid               = 496
      $home              = '/var/lib/clamav'
      $shell             = '/sbin/nologin'
      $group             = 'clam'
      $groups            = undef

      # ### clamd vars ####
      $clamd_package     = 'clamd'
      $clamd_version     = 'installed'
      $clamd_config      = '/etc/clamd.conf'
      $clamd_service     = 'clamd'
      $clamd_options     = {}

      # ### Default values OS specific ####
      $clamd_default_localsocket = '/var/run/clamav/clamd.sock'
      $clamd_default_logfile     = '/var/log/clamav/clamd.log'
      $clamd_default_pidfile     = '/var/run/clamav/clamd.pid'
      $freshclam_default_databaseowner = $user
      $freshclam_default_updatelogfile = '/var/log/clamav/freshclam.log'

      # ### freshclam vars ####
      $freshclam_package = undef
      $freshclam_version = undef
      $freshclam_config  = '/etc/freshclam.conf'
      $freshclam_options = {}
      $freshclam_sysconfig = undef
      $freshclam_delay     = undef
      $freshclam_service   = undef

      # ### clamav_milter vars ####
      $clamav_milter_package     = undef
      $clamav_milter_version     = undef
      $clamav_milter_config      = undef
      $clamav_milter_service     = undef
      $clamav_milter_options     = undef
      $clamav_milter_default_options = undef
    }

    # ### Default values OS specific ####
    $clamd_default_databasedirectory  = '/var/lib/clamav'
    $clamd_default_logrotate          = undef
    $clamd_default_logsyslog          = true
    $clamd_default_temporarydirectory = '/var/tmp'
    $freshclam_default_pidfile        = undef # cron is used

  } elsif ($::osfamily == 'Debian') and (
    (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '7.0') >= 0)) or
    (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '12.0') >= 0))
  ) {
    # ### init vars ####
    $manage_repo       = false
    $clamav_package    = 'clamav'
    $clamav_version    = 'installed'

    # ### user vars ####
    $user              = 'clamav'
    $comment           = undef
    $uid               = 496
    $gid               = 496
    $home              = '/var/lib/clamav'
    $shell             = '/bin/false'
    $group             = 'clamav'
    $groups            = undef

    # ### clamd vars ####
    $clamd_package     = 'clamav-daemon'
    $clamd_version     = 'installed'
    $clamd_config      = '/etc/clamav/clamd.conf'
    $clamd_service     = 'clamav-daemon'
    $clamd_options     = {}

    # ### freshclam vars ####
    $freshclam_package = 'clamav-freshclam'
    $freshclam_version = 'installed'
    $freshclam_config  = '/etc/clamav/freshclam.conf'
    $freshclam_service = 'clamav-freshclam'
    $freshclam_options = {}
    $freshclam_sysconfig = undef
    $freshclam_delay     = undef

    # ### clamav_milter vars ####
    $clamav_milter_package     = undef
    $clamav_milter_version     = undef
    $clamav_milter_config      = undef
    $clamav_milter_service     = undef
    $clamav_milter_options     = undef
    $clamav_milter_default_options = undef

    # ### Default values OS specific ####
    $clamd_default_databasedirectory  = '/var/lib/clamav'
    $clamd_default_localsocket        = '/var/run/clamav/clamd.ctl'
    $clamd_default_logfile            = '/var/log/clamav/clamav.log'
    $clamd_default_logrotate          = true
    $clamd_default_logsyslog          = false
    $clamd_default_pidfile            = '/var/run/clamav/clamd.pid'
    $clamd_default_temporarydirectory = '/tmp'
    $freshclam_default_databaseowner  = $user
    $freshclam_default_pidfile        = '/var/run/clamav/freshclam.pid'
    $freshclam_default_updatelogfile  = '/var/log/clamav/freshclam.log'

  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

  $clamd_default_options = {
    'AlgorithmicDetection'           => true,
    'AllowAllMatchScan'              => true,
    'ArchiveBlockEncrypted'          => false,
    'Bytecode'                       => true,
    'BytecodeSecurity'               => 'TrustSigned',
    'BytecodeTimeout'                => '60000',
    'CommandReadTimeout'             => '5',
    'CrossFilesystems'               => true,
    'DatabaseDirectory'              => $clamd_default_databasedirectory,
    'Debug'                          => false,
    'DetectBrokenExecutables'        => false,
    'DetectPUA'                      => false,
    'DisableCertCheck'               => false,
    'ExitOnOOM'                      => false,
    'ExtendedDetectionInfo'          => true,
    'FixStaleSocket'                 => true,
    'FollowDirectorySymlinks'        => false,
    'FollowFileSymlinks'             => false,
    'ForceToDisk'                    => false,
    'Foreground'                     => false,
    'HeuristicScanPrecedence'        => false,
    'IdleTimeout'                    => '30',
    'LeaveTemporaryFiles'            => false,
    'LocalSocket'                    => $clamd_default_localsocket,
    'LocalSocketGroup'               => $group,
    'LocalSocketMode'                => '666',
    'LogClean'                       => false,
    'LogFacility'                    => 'LOG_LOCAL6',
    'LogFile'                        => $clamd_default_logfile,
    'LogFileMaxSize'                 => '0',
    'LogFileUnlock'                  => false,
    'LogRotate'                      => $clamd_default_logrotate,
    'LogSyslog'                      => $clamd_default_logsyslog,
    'LogTime'                        => true,
    'LogVerbose'                     => false,
    'MaxConnectionQueueLength'       => '15',
    'MaxDirectoryRecursion'          => '15',
    'MaxEmbeddedPE'                  => '10M',
    'MaxHTMLNoTags'                  => '2M',
    'MaxHTMLNormalize'               => '10M',
    'MaxQueue'                       => '100',
    'MaxScriptNormalize'             => '5M',
    'MaxThreads'                     => '12',
    'MaxZipTypeRcg'                  => '1M',
    'OLE2BlockMacros'                => false,
    'OfficialDatabaseOnly'           => false,
    'PhishingAlwaysBlockCloak'       => false,
    'PhishingAlwaysBlockSSLMismatch' => false,
    'PhishingScanURLs'               => true,
    'PhishingSignatures'             => true,
    'PidFile'                        => $clamd_default_pidfile,
    'ReadTimeout'                    => '180',
    'ScanArchive'                    => true,
    'ScanELF'                        => true,
    'ScanHTML'                       => true,
    'ScanMail'                       => true,
    'ScanOLE2'                       => true,
    'ScanOnAccess'                   => false,
    'ScanPE'                         => true,
    'ScanPartialMessages'            => false,
    'ScanSWF'                        => true,
    'SelfCheck'                      => '3600',
    'SendBufTimeout'                 => '200',
    'StreamMaxLength'                => '25M',
    'StructuredDataDetection'        => false,
    'TemporaryDirectory'             => $clamd_default_temporarydirectory,
    'User'                           => $user,
  }

  $freshclam_default_options = {
    'Bytecode'                 => true,
    'Checks'                   => '24',
    'CompressLocalDatabase'    => 'no',
    'ConnectTimeout'           => '30',
    'DNSDatabaseInfo'          => 'current.cvd.clamav.net',
    'DatabaseDirectory'        => $clamd_default_databasedirectory,
    'DatabaseMirror'           => ['db.local.clamav.net', 'database.clamav.net'],
    'DatabaseOwner'            => $freshclam_default_databaseowner,
    'Debug'                    => false,
    'Foreground'               => false,
    'LogFacility'              => 'LOG_LOCAL6',
    'LogFileMaxSize'           => '0',
    'LogRotate'                => $clamd_default_logrotate,
    'LogSyslog'                => $clamd_default_logsyslog,
    'LogTime'                  => true,
    'LogVerbose'               => false,
    'MaxAttempts'              => '5',
    'PidFile'                  => $freshclam_default_pidfile,
    'ReceiveTimeout'           => '30',
    'ScriptedUpdates'          => 'yes',
    'TestDatabases'            => 'yes',
    'UpdateLogFile'            => $freshclam_default_updatelogfile,
  }
}
