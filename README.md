clamav
=============

[![Build Status](https://travis-ci.org/edestecd/puppet-clamav.svg)](https://travis-ci.org/edestecd/puppet-clamav)
[![Puppet Forge](https://img.shields.io/puppetforge/v/edestecd/clamav.svg)](https://forge.puppetlabs.com/edestecd/clamav)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/edestecd/clamav.svg)](https://forge.puppetlabs.com/edestecd/clamav)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/edestecd/clamav.svg)](https://forge.puppetlabs.com/edestecd/clamav/scores)
[![Issue Stats](http://issuestats.com/github/edestecd/puppet-clamav/badge/pr?style=flat)](http://issuestats.com/github/edestecd/puppet-clamav)

####Table of Contents

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

##Overview

Puppet Module to install/configure clamd and freshclam on Debian and RedHat

##Module Description

The clamav module provides some classes to install and configure most of the components of clamav.  
You may also choose to manage only the parts that you need.  
This module aims to be minimalistic.  
No options produces stock config files as provided by your package installer.

This module has the following components that can be managed (or not):
* Base clamav package - command line and libs
* clamav user
* clam daemon
* freshclam daemon/cron (dependent on OS)

##Setup

###What clamav affects

* clamav/clamd/freshclam package install
* clamav/clamd/freshclam config files
* clamd/freshclam services or daily cron on redhat
* clam user/group (optional)

###Setup Requirements

only need to install the module

###Beginning with clamav

Minimal clamav package install for command line use:

```puppet
include clamav
```

##Usage

###Manage the clam and freshclam daemon with stock config

```puppet
class { 'clamav':
  manage_clamd             => true,
  manage_freshclam         => true,
  clamd_service_ensure     => 'running',
  freshclam_service_ensure => 'stopped',
}
```

###Also manage the clam user and group

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

###Customize the clamd and freshclam config

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

###Configure with hiera yaml

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

##Reference

### Classes

* clamav
* clamav::user
* clamav::clamd
* clamav::freshclam

##Limitations

This module has been built on and tested against Puppet 3.8 and higher.  
While I am sure other versions work, I have not tested them.

This module supports modern RedHat and Debian based systems.  
No plans to support other versions (unless you add it :)..

##Development

Pull Requests welcome
