# params.pp
# Set up ClamAV parameters defaults etc.
#
# @Todo: add osx support with ClamXav
#

class clamav::params {

  #### init vars ####
  $manage_user              = false
  $manage_clamd             = false
  $manage_freshclam         = false
  $clamd_service_ensure     = 'running'
  $clamd_service_enable     = true
  $freshclam_service_ensure = 'running'
  $freshclam_service_enable = true

  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    #### init vars ####
    $manage_repo    = true
    $clamav_package = 'clamav'
    $clamav_version = 'installed'

    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
      #### user vars ####
      $user              = 'clamscan'
      $comment           = 'Clamav scanner user'
      $uid               = 496
      $gid               = 496
      $home              = '/'
      $shell             = '/sbin/nologin'
      $group             = 'clamscan'
      $groups            = undef

      #### clamd vars ####
      $clamd_package     = 'clamav-scanner-systemd'
      $clamd_version     = 'installed'
      $clamd_config      = '/etc/clamd.d/scan.conf'
      $clamd_service     = 'clamd@scan'
      $clamd_options     = {}
      $clamd_default_options = {
        'LogSyslog'                => 'yes',
        'User'                     => 'clamscan',
        'AllowSupplementaryGroups' => 'yes',
      }

      #### freshclam vars ####
      $freshclam_package = 'clamav-update'
      $freshclam_version = 'installed'
      $freshclam_config  = '/etc/freshclam.conf'
      $freshclam_options = {}
      $freshclam_default_options = {
        'LogSyslog'      => 'yes',
        'DatabaseMirror' => 'database.clamav.net',
      }
      $freshclam_sysconfig = '/etc/sysconfig/freshclam'
      $freshclam_delay     = undef
    } else {
      #### user vars ####
      $user              = 'clam'
      $comment           = 'Clam Anti Virus Checker'
      $uid               = 496
      $gid               = 496
      $home              = '/var/lib/clamav'
      $shell             = '/sbin/nologin'
      $group             = 'clam'
      $groups            = undef

      #### clamd vars ####
      $clamd_package     = 'clamd'
      $clamd_version     = 'installed'
      $clamd_config      = '/etc/clamd.conf'
      $clamd_service     = 'clamd'
      $clamd_options     = {}
      $clamd_default_options = {
        'LogFile'                  => '/var/log/clamav/clamd.log',
        'LogFileMaxSize'           => '0',
        'LogTime'                  => 'yes',
        'LogSyslog'                => 'yes',
        'PidFile'                  => '/var/run/clamav/clamd.pid',
        'TemporaryDirectory'       => '/var/tmp',
        'DatabaseDirectory'        => '/var/lib/clamav',
        'LocalSocket'              => '/var/run/clamav/clamd.sock',
        'FixStaleSocket'           => 'yes',
        'MaxConnectionQueueLength' => '30',
        'MaxThreads'               => '50',
        'ReadTimeout'              => '300',
        'User'                     => 'clam',
        'AllowSupplementaryGroups' => 'yes',
        'ScanPE'                   => 'yes',
        'ScanELF'                  => 'yes',
        'DetectBrokenExecutables'  => 'yes',
        'ScanOLE2'                 => 'yes',
        'ScanMail'                 => 'yes',
        'ScanArchive'              => 'yes',
        'ArchiveBlockEncrypted'    => 'no',
      }

      #### freshclam vars ####
      $freshclam_config  = '/etc/freshclam.conf'
      $freshclam_options = {}
      $freshclam_default_options = {
        'DatabaseDirectory' => '/var/lib/clamav',
        'UpdateLogFile'     => '/var/log/clamav/freshclam.log',
        'LogSyslog'         => 'yes',
        'DatabaseOwner'     => 'clam',
        'DatabaseMirror'    => ['db.us.clamav.net', 'db.local.clamav.net'],
      }
      $freshclam_sysconfig = undef
      $freshclam_delay     = undef
    }
  } elsif ($::osfamily == 'Debian') and (
    (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '7.0') >= 0)) or
    (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '12.0') >= 0))
  ) {
    #### init vars ####
    $manage_repo       = false
    $clamav_package    = 'clamav'
    $clamav_version    = 'installed'

    #### user vars ####
    $user              = 'clamav'
    $comment           = undef
    $uid               = 496
    $gid               = 496
    $home              = '/var/lib/clamav'
    $shell             = '/bin/false'
    $group             = 'clamav'
    $groups            = undef

    #### clamd vars ####
    $clamd_package     = 'clamav-daemon'
    $clamd_version     = 'installed'
    $clamd_config      = '/etc/clamav/clamd.conf'
    $clamd_service     = 'clamav-daemon'
    $clamd_options     = {}
    $clamd_default_options = {
      'LocalSocket'                    => '/var/run/clamav/clamd.ctl',
      'FixStaleSocket'                 => true,
      'LocalSocketGroup'               => 'clamav',
      'LocalSocketMode'                => '666',
      'User'                           => 'clamav',
      'AllowSupplementaryGroups'       => true,
      'ScanMail'                       => true,
      'ScanArchive'                    => true,
      'ArchiveBlockEncrypted'          => false,
      'MaxDirectoryRecursion'          => '15',
      'FollowDirectorySymlinks'        => false,
      'FollowFileSymlinks'             => false,
      'ReadTimeout'                    => '180',
      'MaxThreads'                     => '12',
      'MaxConnectionQueueLength'       => '15',
      'LogSyslog'                      => false,
      'LogRotate'                      => true,
      'LogFacility'                    => 'LOG_LOCAL6',
      'LogClean'                       => false,
      'LogVerbose'                     => false,
      'PidFile'                        => '/var/run/clamav/clamd.pid',
      'DatabaseDirectory'              => '/var/lib/clamav',
      'SelfCheck'                      => '3600',
      'Foreground'                     => false,
      'Debug'                          => false,
      'ScanPE'                         => true,
      'MaxEmbeddedPE'                  => '10M',
      'ScanOLE2'                       => true,
      'ScanHTML'                       => true,
      'MaxHTMLNormalize'               => '10M',
      'MaxHTMLNoTags'                  => '2M',
      'MaxScriptNormalize'             => '5M',
      'MaxZipTypeRcg'                  => '1M',
      'ScanSWF'                        => true,
      'DetectBrokenExecutables'        => false,
      'ExitOnOOM'                      => false,
      'LeaveTemporaryFiles'            => false,
      'AlgorithmicDetection'           => true,
      'ScanELF'                        => true,
      'IdleTimeout'                    => '30',
      'PhishingSignatures'             => true,
      'PhishingScanURLs'               => true,
      'PhishingAlwaysBlockSSLMismatch' => false,
      'PhishingAlwaysBlockCloak'       => false,
      'DetectPUA'                      => false,
      'ScanPartialMessages'            => false,
      'HeuristicScanPrecedence'        => false,
      'StructuredDataDetection'        => false,
      'CommandReadTimeout'             => '5',
      'SendBufTimeout'                 => '200',
      'MaxQueue'                       => '100',
      'ExtendedDetectionInfo'          => true,
      'OLE2BlockMacros'                => false,
      'ScanOnAccess'                   => false,
      'AllowAllMatchScan'              => true,
      'ForceToDisk'                    => false,
      'DisableCertCheck'               => false,
      'StreamMaxLength'                => '25M',
      'LogFile'                        => '/var/log/clamav/clamav.log',
      'LogTime'                        => true,
      'LogFileUnlock'                  => false,
      'LogFileMaxSize'                 => '0',
      'Bytecode'                       => true,
      'BytecodeSecurity'               => 'TrustSigned',
      'BytecodeTimeout'                => '60000',
      'OfficialDatabaseOnly'           => false,
      'CrossFilesystems'               => true,
    }

    #### freshclam vars ####
    $freshclam_package = 'clamav-freshclam'
    $freshclam_version = 'installed'
    $freshclam_config  = '/etc/clamav/freshclam.conf'
    $freshclam_service = 'clamav-freshclam'
    $freshclam_options = {}
    $freshclam_default_options = {
      'DatabaseOwner'            => 'clamav',
      'UpdateLogFile'            => '/var/log/clamav/freshclam.log',
      'LogVerbose'               => false,
      'LogSyslog'                => false,
      'LogFacility'              => 'LOG_LOCAL6',
      'LogFileMaxSize'           => '0',
      'LogRotate'                => true,
      'LogTime'                  => true,
      'Foreground'               => false,
      'Debug'                    => false,
      'MaxAttempts'              => '5',
      'DatabaseDirectory'        => '/var/lib/clamav',
      'DNSDatabaseInfo'          => 'current.cvd.clamav.net',
      'AllowSupplementaryGroups' => false,
      'PidFile'                  => '/var/run/clamav/freshclam.pid',
      'ConnectTimeout'           => '30',
      'ReceiveTimeout'           => '30',
      'TestDatabases'            => 'yes',
      'ScriptedUpdates'          => 'yes',
      'CompressLocalDatabase'    => 'no',
      'Bytecode'                 => true,
      'Checks'                   => '24',
      'DatabaseMirror'           => ['db.local.clamav.net', 'database.clamav.net'],
    }
    $freshclam_sysconfig = undef
    $freshclam_delay     = undef
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

}
