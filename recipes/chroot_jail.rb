#
# Cookbook Name:: et_upload
# Recipe:: chroot_jail
#
# Copyright (C) 2014 EverTrue, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory node['et_upload']['chroot_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

jk_init_ini_path     = node['jailkit']['jk_init_ini_path']
jk_chrootsh_ini_path = node['jailkit']['jk_chrootsh_ini_path']
jk_path              = node['jailkit']['path']

[jk_init_ini_path, jk_chrootsh_ini_path].each do |file_path|
  cookbook_file file_path do
    path file_path
    owner 'root'
    group 'root'
    only_if "test -d #{jk_path}"
  end
end

execute 'jk_init' do
  command "jk_init -j #{node['et_upload']['chroot_path']} jk_lsh scp sftp ssh rsync"
  action :run
  only_if "test -f #{jk_init_ini_path}"
end
