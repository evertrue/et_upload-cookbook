set['jailkit']['url'] = 'http://olivier.sessink.nl/jailkit'
set['jailkit']['version'] = '2.17'
set['jailkit']['checksum'] = '7b5a68abe89a65e0e29458cc1fd9ad0b'
set['jailkit']['path'] = '/etc/jailkit'
set['jailkit']['jk_ini_path'] = "#{node['jailkit']['path']}/jk_init.ini"

default['et_upload']['chroot_dirs'] = %w(
  bin
  dev
  etc
  etc/pam.d
  home
  lib
  lib64
  sbin
  usr
  usr/bin
  usr/lib
)
default['et_upload']['chroot_path'] = '/usr/chroot'
default['et_upload']['chroot_home'] = "#{node['et_upload']['chroot_path']}/home"
