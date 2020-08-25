# Changelog

All notable changes to this project will be documented in this file.

## 2020-08-25 (2.0.0)  Chris Edester
* PDK support at 1.18.0
* Puppet 5/6ish support
* Drop Puppet 3 support
* Update puppetlabs/stdlib dependency
* Switch to puppet/epel dependency

## 2016-08-10 (1.0.0)  Chris Edester
* WARNING: Major revision, will most likely change your configs, especially on RedHat (Please test first)
* Refactor private class params and specs
* RedHat uses the same template and hash as Debian, allowing you to unset options by passing undef
* RedHat 7.x support
* Default config options are the same across all supported OSes
* Manage /etc/sysconfig/freshclam on RedHat 7
* Comply with Puppet 4 strict variables

## 2016-05-08 (0.5.0)  Chris Edester
* Move the freshclam package ordering out of service definition
* Add enable param to clamd and freshclam services
* Adding option to set specific version number for package installs

## 2015-11-29 (0.4.0)  Chris Edester
* add tests
* parameters to set service ensure

## 2015-06-01 (0.3.1)  Daniel Rosenbloom
* fixes #7 no need to validate $groups if it is still undef

## 2015-03-27 (0.3.0)  Chris Edester
* fixes #5 Hash iteration order in ruby 1.8.7
* Allow to unset default config_options

## 2015-03-19 (0.2.3)  Patrick Schönfeld
* Allow specification of groups for clamav user

## 2015-03-19 (0.2.2)  Chris Edester
* fix lint errors and add rubocop

## 2015-02-04 (0.2.1)  Chris Edester
* update license identifier in metadata.json

## 2015-02-04 (0.2.0)  Chris Edester
* try to fix lint errors

## 2015-02-04 (0.1.4)  Chris Edester
* fixes #2 Use Debian versioning on operatingsystem Debian

## 2015-02-04 (0.1.3)  Chris Edester
* fixes #1 Make EPEL repo install optional

## 2014-10-29 (0.1.2)  Chris Edester
* puppet lint checks and improved version comparison

## 2014-09-15 (0.1.1)  Chris Edester
* compatability with puppet 3.7 and future parser

## 2014-07-01 (0.1.0)  Chris Edester
* Document and publish

## 2014-06-04 (0.0.7)  Chris Edester
* Debian config file options working

## 2014-06-04 (0.0.5)  Chris Edester
* RedHat config file options working

## 2014-06-04 (0.0.4)  Chris Edester
* Start work on config options

## 2014-06-02 (0.0.3)  Chris Edester
* Add user class and base templates

## 2014-06-02 (0.0.2)  Chris Edester
* Add clamd and freshclam classes

## 2014-05-30 (0.0.1)  Chris Edester
* Initial Commit of default files etc.
