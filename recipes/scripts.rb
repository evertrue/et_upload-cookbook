#
# Cookbook Name:: et_upload
# Recipe:: scripts
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

%w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
  directory path do
    owner 'root'
    group 'root'
    recursive true
  end
end

%w(provision_user.sh show_uploads.sh process_uploads.sh).each do |file|
  cookbook_file file do
    path "/opt/evertrue/upload/#{file}"
    owner 'root'
    group 'root'
    mode '0755'
    only_if 'test -d /opt/evertrue/upload'
  end
end

shell  = '/bin/bash'
path   = '/sbin:/bin:/usr/sbin:/usr/bin'
mailto = 'ehren+upload@evertrue.com,hai.zhou+upload@evertrue.com'

cron_d 'show_uploads' do
  minute  0
  hour    '*/4'
  command '/opt/evertrue/upload/show_uploads.sh'
  user    'root'
  shell   shell
  path    path
  mailto  mailto
end

cron_d 'process_uploads' do
  minute  0
  command '/opt/evertrue/upload/process_uploads.sh'
  user    'root'
  shell   shell
  path    path
  mailto  mailto
end

cron_d 'clean_uploads' do
  minute   15
  hour     0
  command  '/bin/find /var/evertrue/uploads/* -mtime +7 -exec /bin/rm {} \;'
  user    'root'
  shell    shell
  path     path
  mailto   mailto
end
