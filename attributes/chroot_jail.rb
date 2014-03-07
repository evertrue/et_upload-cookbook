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
