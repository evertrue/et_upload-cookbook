et_upload cookbook CHANGELOG
============================
This file is used to list changes made in each version of the et_upload cookbook.

5.1.26 (2021-03-01)
-------------------
* Added a reporting folder to all clients

5.1.22 (2020-01-15)
------------------
* Need to shellword escape the file name in gzip command

5.1.22 (2020-01-13)
------------------
* Use gzip command for compressing files
* Ensure files are in the uploads folders and not a subfolder

v5.1.21 (2020-01-13)
------------------
* Added partner upload support

v5.1.19 (2019-03-07)
------------------
* Added new solicitors file type to upload process

v5.1.17 (2019-02-07)
------------------
* Upload files in the order we receive them

v5.1.15 (2019-01-11)
------------------
* Run process_uploads every 2 minutes now that missing org files have been removed

v5.1.14 (2019-01-11)
------------------
* Fix for capturing mtime before deleting file

v5.1.13 (2019-01-11)
------------------
* Remove files from orgs that are not found

v5.1.12 (2019-01-11)
------------------
* Run process_uploads every 5 minutes

v5.1.11 (2018-12-21)
------------------

* Notify customer support about invalid zip files

v5.1.10 (2018-06-19)
------------------

* Use newer version of gem

v5.1.9 (2018-06-19)
------------------

* Update evertrue group permissions on uploads and exports

v5.1.8 (2018-05-31)
------------------

* Revert group change on the home dir

v5.1.7 (2018-05-30)
------------------

* Fix .ssh permission

v5.1.6 (2018-05-30)
------------------

* Give evertrue user permission to see inside upload users' home dir

v5.1.5 (2018-04-09)
------------------

* Blake blew out a return statement for the s3_filename, put that back
  in

v5.1.3 (2018-03-19)
------------------

* File naming convention can be singular

v5.1.2 (2018-03-03)
------------------

* Only download export once

v5.1.1 (2017-08-11)
------------------

* Add special exception for yale

v5.1.0 (2017-08-11)
------------------

* Process assignment imports

v5.0.5 (2017-07-11)
------------------

* Log scheduled export to a different file

v5.0.4 (2017-07-11)
------------------

* Run scheduled export job every 10 minutes
* Clean scheduled export every 90 days

v5.0.3 (2017-07-11)
------------------

* Remove extension from process scheduled export.

v5.0.2 (2017-07-11)
------------------

* Add process scheduled export to the cookbook file.

v5.0.1 (2017-07-11)
------------------

* Process Scheduled Exports: Add script to process latest scheduled exports from CAPI per org.

v4.0.0 (2017-01-25)
------------------

* Process uploads: Make sure the algorithm for REMOVING slug random numbers matches the one for adding them

v3.0.7 (2016-12-13)
------------------

* Process uploads: Make sure the algorithm for REMOVING slug random numbers matches the one for adding them

v3.0.6 (2016-09-20)
------------------

* Add reboot coordinator exemption

v3.0.5 (2016-08-09)
------------------

* Have upload scripts use their own sentry dsn

v3.0.4 (2016-7-01)
------------------

* Fix bug with pagerduty key

v3.0.3 (2016-6-28)
------------------

* Add support for interaction imports

v3.0.2 (2016-4-12)
------------------

* Add support for full gift imports

v3.0.1 (2016-4-12)
------------------

* Add email notification support for genius@evertrue.com

v3.0.0 (2016-03-28)
-------------------

* Upgrade to Ruby 2.0 for upload processing scripts

v2.3.7 (2016-03-25)
-------------------

* Use sudo to allow group evertrue users to run chef-client and restart the service

v2.3.6 (2016-02-26)
-------------------

* Don't fail the process_uploads script for API response codes of 400,
  since it keeps other files from being processed

v2.3.5 (2015-09-25)
-------------------

* Re-enable pagerduty for the process uploads script
* Send support emails to onboarding instead of Jenna
* Use env var `DEBUG_EMAIL` instead of `alex@evertrue.com`

v2.3.4 (2015-09-10)
-------------------

* Fixes authentication issue when hitting new DNA endpoint

v2.3.3 (2015-09-10)
-------------------

* Use non-legacy DNA endpoint for org setting values

v2.3.2 (2015-09-08)
-------------------

* Rotate logs weekly to get a better historical view of import statuses

v2.3.1 (2015-08-29)
-------------------

* Fix bug causing script to fail in production

v2.3.0 (2015-08-28)
-------------------

* Many improvements to the process uploads script (mostly more logging and alerting)

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
