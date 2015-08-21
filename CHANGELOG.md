et_upload cookbook CHANGELOG
============================
This file is used to list changes made in each version of the et_upload cookbook.

v2.2.2 (2015-08-21)
-------------------

* Resolve script error that prevents DNA updates for unrecognized csv
  headers

v2.2.1 (2015-08-05)
-------------------

* `s/work_dir/archive_dir/`

v2.2.0 (2015-08-05)
-------------------

* Refactor the process uploads script
* Move working directory and uploads (users) directories to ephemeral storage
* Add support for header changes

v2.1.2 (2015-07-24)
-------------------

* Add tests for general Contact import path in process_uploads

v2.1.1 (2015-07-23)
-------------------

* Filter out users with action property set to 'remove'

v2.1.0 (2015-07-23)
-------------------

* Allow Transactional Gift file processing through the process_uploads
  script

v2.0.18 (2015-07-23)
-------------------

* Refactor process_upload script and surrounding infrastructure
* Testing on Ubuntu 14.4
* Add integration test for process_upload script
* Many minor bug fixes and improvements

v2.0.17 (2015-04-27)
-------------------

* Handle user deletes

v2.0.16 (2015-04-27)
-------------------

* Remove legacy code path

v2.0.15 (2015-04-13)
-------------------

* Use greater-than version constraint for cron cookbook

v2.0.14 (2015-02-24)
-------------------

* Fix hostname for hb

v2.0.13 (2014-08-13)
-------------------

* Add notification when queueing a job

v2.0.12 (2014-07-30)
-------------------

* Escape spaces only for shell exec

v2.0.11 (2014-06-26)
-------------------

* Escape spaces in filenames

v2.0.10 (2014-06-24)
-------------------

* Change auto-ingestion flow to only gate new importer queuing

v2.0.9 (2014-06-11)
-------------------

* Fix syntax error

v2.0.8 (2014-06-10)
-------------------

* Ensure no duplicate submissions due to timeout

v2.0.7 (2014-06-10)
-------------------

* Clean up unused file open block

v2.0.6 (2014-06-10)
-------------------

* Handle individual file failure
* Fix chefspec tests

v2.0.5 (2014-06-06)
-------------------

* Fix job queueing flow (thanks @haizhou)

v2.0.4 (2014-05-01)
-------------------
- Use console gate to route imports

v2.0.3
------
- Fix issue with mismatched username/OID, properly rescue DNA

v2.0.2
------
- Pin to cron v1.3.8 to avoid "predefined_value" bug.

v2.0.1
------
- Fix script to skip processing of trial user uploads

v2.0.0
------
- Refactor upload processing scripts to ship import data to S3

v1.6.0
------
- Remove @ehrenfoss from cronjob MAILTO notifications

v1.5.1
------
- Adjust code so any user with a username includes the string `trial` is treated as a shared trial user

v1.5.0
------
- Add `trial-user` shared SFTP account to use for trial customers to improve security
- Adjust tests to check permissions properly for `trial-user` uploads directory

v1.4.0
------
- Refactor scripts to only search users based on upload users data bag item content
- Fix FC023 in `et_upload::users`
- Add installation of Ruby 1.9.1 & aws-sdk RubyGem
    - Paves way forward for using Ruby for scripts instead of Bash
- Add ChefSpec & ServerSpec tests for newly created functionality

v1.3.1
------
- Fix name of script that had been renamed

v1.3.0
------
- Add Ehren to cronjob notifications
- Remove email notification for cleanup cronjob
- Refactor user provision script to a username & password generation script
- Change path for `find` to be relative
- Fix path to uploads users' home folders

v1.2.0
------
- Add Serverspec integration tests
- Tweak ChefSpec tests to use test data bag item, consistent w/ Serverspec

v1.1.0
------
- Add ChefSpec unit tests

v1.0.1
------
- Fix mode of scripts to be executable

v1.0.0
------
- Use OpenSSH’s built-in SFTP user jailing instead of building a chroot jail

v0.3.0
------
- Add setup of chroot jail using [Jailkit](http://olivier.sessink.nl/jailkit/)

v0.2.0
------
- Fix user creation to add all necessary folders & set ownership properly
- Add authorized_keys template exists
- Add Test Kitchen config for Chef Zero

v0.1.0 (2014-03-06)
-------------------
- Initial release of et_upload
