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

directory "#{node['et_upload']['base_dir']}/users" do
  recursive true
end

group 'uploadonly' do
  action :create
end

upload_users = data_bag_item('users', 'upload').select { |uname| uname != 'id' }

upload_users.each do |uname, u|
  u['home'] = "#{node['et_upload']['base_dir']}/users/#{uname}"
  u['gid'] = 'uploadonly'
  evertrue_gid = 'evertrue'

  if u['action'] == 'remove'
    user uname do
      uid u['uid']
      gid u['gid']
      action :remove
    end

    directory u['home'] do
      action :delete
      recursive true
    end
  else
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
      group evertrue_gid
      mode '0750'
      action :create
    end

    directory "#{u['home']}/.ssh" do
      owner uname
      group u['gid']
      mode '0750'
    end

    %w(uploads exports).each do |dir|
      directory "#{u['home']}/#{dir}" do
        owner uname
        group evertrue_gid
        mode '0750'
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
end
