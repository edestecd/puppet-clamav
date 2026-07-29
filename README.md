clamav
=============

[![Build Status](https://travis-ci.org/edestecd/puppet-clamav.svg)](https://travis-ci.org/edestecd/puppet-clamav)
[![Puppet Forge](https://img.shields.io/puppetforge/v/edestecd/clamav.svg)](https://forge.puppet.com/edestecd/clamav)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/edestecd/clamav.svg)](https://forge.puppet.com/edestecd/clamav)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/edestecd/clamav.svg)](https://forge.puppet.com/edestecd/clamav/scores)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with clamav](#setup)
    * [What clamav affects](#what-clamav-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with clamav](#beginning-with-clamav)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors](#contributors)

## Overview

Puppet Module to install/configure clamd and freshclam on Debian and RedHat

## Module Description

The clamav module provides classes to install and configure the main ClamAV
components. You may manage only the components you need. The module supplies
baseline configuration defaults and combines them with platform data and
caller overrides.

This module has the following components that can be managed (or not):
* Base clamav package - command line and libs
* clamav user
* clam daemon
* freshclam daemon/cron (dependent on OS)
* clamav-milter (RHEL7 and derivatives only for now)

## Setup

### What clamav affects

* clamav/clamd/freshclam package install
* clamav/clamd/freshclam config files
* clamd/freshclam services or daily cron on redhat
* clamav-milter package install, config files, service (optional)
* clam user/group (optional)

### Setup Requirements

Install the module and its dependencies. On Red Hat-family systems,
`manage_repo` defaults to `true` and declares the module's `puppet/epel`
dependency. Set `manage_repo => false` when repository management is provided
elsewhere.

### Beginning with clamav

Minimal clamav package install for command line use:

```puppet
include clamav
```

## Usage

### Manage the clam and freshclam daemon with stock config

```puppet
class { 'clamav':
  manage_clamd             => true,
  manage_freshclam         => true,
  clamd_service_ensure     => 'running',
  freshclam_service_ensure => 'stopped',
}
```

### Also manage the clam user and group

```puppet
class { 'clamav':
  manage_user      => true,
  uid              => 499,
  gid              => 499,
  shell            => '/sbin/nologin',
  manage_clamd     => true,
  manage_freshclam => true,
}
```

### Customize the clamd and freshclam config

```puppet
class { 'clamav':
  manage_clamd      => true,
  manage_freshclam  => true,
  clamd_options     => {
    'MaxScanSize' => '500M',
    'MaxFileSize' => '150M',
  },
  freshclam_options => {
    'LogTime'         => 'yes',
    'HTTPProxyServer' => 'myproxy.proxy.com',
    'HTTPProxyPort'   => '80',
    'NotifyClamd'     => '/etc/clamd.conf',
    'DatabaseMirror'  => [
      'clam.host1.mydomain.com',
      'clam.host2.mydomain.com',
    ],
  },
}
```

### Understand clamd option precedence

When `clamd_default_options` is not supplied, the generated configuration uses
these layers, with later values taking precedence:

1. Module baseline options.
2. OS-family platform options.
3. Caller-supplied `clamd_options`.

For compatibility with earlier releases, explicitly supplying
`clamd_default_options` replaces both the module baseline and platform
defaults. `clamd_options` is then applied over that replacement hash. A
replacement hash must therefore contain every default required by the target
system.

An option whose value is `undef` or an empty string is omitted. Arrays render
the directive once for each non-empty element. Boolean values retain the
module's established `true` and `false` rendering.

### Enable clamd socket activation explicitly

Direct service management remains the default. Debian-family systems provide
`clamav-daemon.socket` as the default socket unit, but it is used only when
socket activation is explicitly enabled:

```puppet
class { 'clamav':
  manage_clamd     => true,
  clamd_use_socket => true,
}
```

The module keeps the direct clamd service stopped and disabled while the
socket unit is active. A custom socket unit can be supplied with
`clamd_socket`. Enabling socket activation on a platform without a socket-unit
default requires an explicit `clamd_socket` value.

The compatibility configuration renders `LocalSocketMode 666`, allowing any
local account that can reach the socket path to connect. Sites that do not
require world-accessible scanning should restrict the socket to its configured
group:

```puppet
class { 'clamav':
  manage_clamd  => true,
  clamd_options => {
    'LocalSocketMode' => '660',
  },
}
```

Ensure every local client that needs the socket belongs to the configured
`LocalSocketGroup` before applying a restrictive mode. The module retains
`666` as its compatibility default; changing that default requires a
separately documented migration.

### Understand freshclam service policy

Debian-family systems manage the `clamav-freshclam` service directly.
Red Hat-family EL7 packages use their cron-based update behavior, so the
module does not declare a freshclam service there. EL8 manages the
`clamav-freshclam` service and its `/etc/sysconfig/freshclam` environment
file.

### Add clamav-milter support and customize its config (RHEL7 and derivatives only)
#### Please note that as of RHEL 7.2 only the TCP socket has been tested successfully

```puppet
class { 'clamav':
  manage_repo           => false,
  clamd_options         => {
    'TCPSocket' => '3310',
    'TCPAddr'   => '127.0.0.1',
  },

  clamav_milter_options => {
    'AddHeader'  => 'add',
    'OnInfected' => 'Reject',
    'RejectMsg'  => 'Message rejected: Infected by %v',
  },

  manage_clamd          => true,
  manage_freshclam      => true,
  manage_clamav_milter  => true,
  clamd_service_ensure  => 'running',
}
```

### Configure with hiera yaml

```puppet
include clamav
```
```yaml
---
clamav::manage_clamd: true
clamav::manage_freshclam: true

clamav::clamd_options:
  MaxScanSize: 500M
  MaxFileSize: 150M
clamav::freshclam_options:
  LogTime: yes
  HTTPProxyServer: myproxy.proxy.com
  HTTPProxyPort: 80
  NotifyClamd: /etc/clamd.conf
  DatabaseMirror:
  - clam.host1.mydomain.com
  - clam.host2.mydomain.com
```

## Reference

### Classes

* clamav
* clamav::user
* clamav::clamd
* clamav::freshclam
* clamav::clamav_milter

## Limitations

The supported Puppet and operating-system ranges are declared in
`metadata.json`. Catalog compilation in CI does not replace runtime acceptance
testing of package availability, generated configuration, database updates,
or service startup.

ClamAV 1.5+, Ubuntu 26.04, Debian 13, EL10, and OpenVox 8 have not been
runtime-validated by this work and are not additional support claims.

## Development

Use the repository's Bundler environment:

```shell
bundle exec rake validate
bundle exec rake spec
```

GitHub Actions runs four Puppet 8/Ruby 3.3 jobs:

* Metadata, Puppet syntax, Hiera, and Ruby style validation.
* A focused compatibility suite for configuration precedence and
  platform-sensitive behavior.
* The complete unit suite across the operating systems declared in metadata.
* Catalog integration with the pinned `puppet/epel` 5.0.0 fixture for EL7.9
  and EL9.

The EPEL coverage verifies catalog relationships, repository resources, and
signing-key resources. It is not a package-installation acceptance test.

Pull requests should describe the affected operating systems, Puppet and
ClamAV versions, compatibility impact, and tests run.
