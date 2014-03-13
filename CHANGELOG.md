et_upload cookbook CHANGELOG
============================
This file is used to list changes made in each version of the et_upload cookbook.

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
