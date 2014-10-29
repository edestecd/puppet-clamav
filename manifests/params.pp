# params.pp
# Set up ClamAV parameters defaults etc.
#
# @Todo: add osx support with ClamXav
#

class clamav::params {

  #### init vars ####
  $manage_user      = false
  $manage_clamd     = false
  $manage_freshclam = false


  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    #### init vars ####
    $clamav_package    = 'clamav'

    #### user vars ####
    $user              = 'clam'
    $comment           = 'Clam Anti Virus Checker'
    $uid               = 496
    $gid               = 496
    $home              = '/var/lib/clamav'
    $shell             = '/sbin/nologin'
    $group             = 'clam'

    #### clamd vars ####
    $clamd_package     = 'clamd'
    $clamd_config      = '/etc/clamd.conf'
    $clamd_service     = 'clamd'
    $clamd_options     = {}
    $clamd_default_options = {
    }

    #### freshclam vars ####
    $freshclam_config  = '/etc/freshclam.conf'
    $freshclam_options = {}
    $freshclam_default_options = {
    }
  } elsif ($::osfamily == 'Debian') and (versioncmp($::operatingsystemrelease, '12.0') >= 0) {
    #### init vars ####
    $clamav_package    = 'clamav'

    #### user vars ####
    $user              = 'clamav'
    $comment           = undef
    $uid               = 496
    $gid               = 496
    $home              = '/var/lib/clamav'
    $shell             = '/bin/false'
    $group             = 'clamav'

    #### clamd vars ####
    $clamd_package     = 'clamav-daemon'
    $clamd_config      = '/etc/clamav/clamd.conf'
    $clamd_service     = 'clamav-daemon'
    $clamd_options     = {}
    # These are actual config file strings
    # lint:ignore:quoted_booleans
    $clamd_default_options = {
      'User'                           => 'clamav',
      'AllowSupplementaryGroups'       => 'true',
      'ScanMail'                       => 'true',
      'ScanArchive'                    => 'true',
      'ArchiveBlockEncrypted'          => 'false',
      'MaxDirectoryRecursion'          => '15',
      'FollowDirectorySymlinks'        => 'false',
      'FollowFileSymlinks'             => 'false',
      'ReadTimeout'                    => '180',
      'MaxThreads'                     => '12',
      'MaxConnectionQueueLength'       => '15',
      'LogSyslog'                      => 'false',
      'LogRotate'                      => 'true',
      'LogFacility'                    => 'LOG_LOCAL6',
      'LogClean'                       => 'false',
      'LogVerbose'                     => 'false',
      'PidFile'                        => '/var/run/clamav/clamd.pid',
      'DatabaseDirectory'              => '/var/lib/clamav',
      'SelfCheck'                      => '3600',
      'Foreground'                     => 'false',
      'Debug'                          => 'false',
      'ScanPE'                         => 'true',
      'MaxEmbeddedPE'                  => '10M',
      'ScanOLE2'                       => 'true',
      'ScanHTML'                       => 'true',
      'MaxHTMLNormalize'               => '10M',
      'MaxHTMLNoTags'                  => '2M',
      'MaxScriptNormalize'             => '5M',
      'MaxZipTypeRcg'                  => '1M',
      'ScanSWF'                        => 'true',
      'DetectBrokenExecutables'        => 'false',
      'ExitOnOOM'                      => 'false',
      'LeaveTemporaryFiles'            => 'false',
      'AlgorithmicDetection'           => 'true',
      'ScanELF'                        => 'true',
      'IdleTimeout'                    => '30',
      'PhishingSignatures'             => 'true',
      'PhishingScanURLs'               => 'true',
      'PhishingAlwaysBlockSSLMismatch' => 'false',
      'PhishingAlwaysBlockCloak'       => 'false',
      'DetectPUA'                      => 'false',
      'ScanPartialMessages'            => 'false',
      'HeuristicScanPrecedence'        => 'false',
      'StructuredDataDetection'        => 'false',
      'CommandReadTimeout'             => '5',
      'SendBufTimeout'                 => '200',
      'MaxQueue'                       => '100',
      'ExtendedDetectionInfo'          => 'true',
      'OLE2BlockMacros'                => 'false',
      'ScanOnAccess'                   => 'false',
      'AllowAllMatchScan'              => 'true',
      'ForceToDisk'                    => 'false',
      'DisableCertCheck'               => 'false',
      'StreamMaxLength'                => '25M',
      'LogFile'                        => '/var/log/clamav/clamav.log',
      'LogTime'                        => 'true',
      'LogFileUnlock'                  => 'false',
      'LogFileMaxSize'                 => '0',
      'Bytecode'                       => 'true',
      'BytecodeSecurity'               => 'TrustSigned',
      'BytecodeTimeout'                => '60000',
      'OfficialDatabaseOnly'           => 'false',
      'CrossFilesystems'               => 'true',
    }
    # lint:endignore

    #### freshclam vars ####
    $freshclam_package = 'clamav-freshclam'
    $freshclam_config  = '/etc/clamav/freshclam.conf'
    $freshclam_service = 'clamav-freshclam'
    $freshclam_options = {}
    # These are actual config file strings
    # lint:ignore:quoted_booleans
    $freshclam_default_options = {
      'DatabaseOwner'            => 'clamav',
      'UpdateLogFile'            => '/var/log/clamav/freshclam.log',
      'LogVerbose'               => 'false',
      'LogSyslog'                => 'false',
      'LogFacility'              => 'LOG_LOCAL6',
      'LogFileMaxSize'           => '0',
      'LogRotate'                => 'true',
      'LogTime'                  => 'true',
      'Foreground'               => 'false',
      'Debug'                    => 'false',
      'MaxAttempts'              => '5',
      'DatabaseDirectory'        => '/var/lib/clamav',
      'DNSDatabaseInfo'          => 'current.cvd.clamav.net',
      'AllowSupplementaryGroups' => 'false',
      'PidFile'                  => '/var/run/clamav/freshclam.pid',
      'ConnectTimeout'           => '30',
      'ReceiveTimeout'           => '30',
      'TestDatabases'            => 'yes',
      'ScriptedUpdates'          => 'yes',
      'CompressLocalDatabase'    => 'no',
      'Bytecode'                 => 'true',
      # Check for new database 24 times a day
      'Checks'                   => '24',
      'DatabaseMirror'           => ['db.local.clamav.net', 'database.clamav.net'],
    }
    # lint:endignore
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

}
