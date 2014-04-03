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

upload_users = data_bag_item('users', 'upload').select { |uname| uname != 'id' }

upload_users.each do |uname, u|
  u['home'] = "/home/#{uname}"
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
    mode '0755'
    action :create
  end

  ["#{u['home']}/.ssh", "#{u['home']}/uploads"].each do |dir|
    mode = uname.include?('trial') && dir.include?('uploads') ? '0300' : '0700'

    directory dir do
      owner uname
      group u['gid']
      mode mode
    end
  end

  template "#{u['home']}/.ssh/authorized_keys" do
    source 'authorized_keys.erb'
    owner uname
    group u['gid']
    mode '0600'
    variables ssh_keys: u['ssh_keys']
    only_if { u['ssh_keys'] }
  end
end
