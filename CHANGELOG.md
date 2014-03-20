et_upload cookbook CHANGELOG
============================
This file is used to list changes made in each version of the et_upload cookbook.

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
