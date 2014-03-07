#
# Cookbook Name:: et_upload
# Recipe:: users
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

group 'uploadonly' do
  action :create
end

directory node['et_upload']['chroot_home']

upload_users = data_bag_item('users', 'upload')
jailed_users = []

upload_users.each do |uname, u|
  if uname != 'id'
    jailed_users << uname

    u['home'] = "#{node['et_upload']['chroot_home']}/#{uname}"
    u['gid'] = 'uploadonly'

    user uname do
      uid u['uid']
      gid u['gid']
      shell '/bin/bash'
      comment u['comment']
      password u['password'] if u['password']
      supports manage_home: true
      home u['home']
    end

    directory u['home'] do
      owner 'root'
      group u['gid']
      mode 0755
    end

    directory "#{u['home']}/.ssh" do
      owner uname
      group u['gid']
      mode '0700'
    end

    if u['ssh_keys']
      template "#{u['home']}/.ssh/authorized_keys" do
        source 'authorized_keys.erb'
        owner u['uname']
        group u['gid']
        mode '0600'
        variables ssh_keys: u['ssh_keys']
      end
    end

    directory "#{u['home']}/.ssh" do
      owner uname
      group u['gid']
      mode 0700
    end

    directory "#{u['home']}/uploads" do
      owner u['name']
      group u['gid']
      mode 0775
    end
  end
end

execute 'jk_init' do
  command "jk_jailuser -j #{node['et_upload']['chroot_path']} " \
          "#{jailed_users.join(' ')}"
  only_if "test -f #{node['jailkit']['jk_ini_path']}"
end
