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

case node['platform_family']
when 'debian'
  include_recipe 'apt'
end

%w(ruby1.9.1 ruby1.9.1-dev).each do |pkg|
  package pkg
end

%w(aws-sdk rubyzip multipart-post).each do |gem_pkg|
  gem_package gem_pkg
end

%w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
  directory path do
    owner 'root'
    group 'root'
    recursive true
  end
end

unames = data_bag_item('users', 'upload').keys.select { |uname| uname != 'id' }

s3_creds = Chef::EncryptedDataBagItem.load(
  'secrets',
  'aws_credentials'
)["Upload-#{node.chef_environment}"]

aws_access_key_id     = s3_creds['access_key_id']
aws_secret_access_key = s3_creds['secret_access_key']

upload_creds = Chef::EncryptedDataBagItem.load(
  'secrets',
  'api_keys'
)[node.chef_environment]['importer']['upload']

upload_app_key    = upload_creds['app_key']
upload_auth_token = upload_creds['auth_token']

%w(show_uploads).each do |file|
  template "/opt/evertrue/upload/#{file}.sh" do
    source "#{file}.erb"
    owner 'root'
    group 'root'
    mode '0755'
    variables unames: unames
    only_if 'test -d /opt/evertrue/upload'
  end
end

%w(process_uploads).each do |file|
  template "/opt/evertrue/upload/#{file}.rb" do
    source "#{file}.erb"
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      unames:                unames,
      aws_access_key_id:     aws_access_key_id,
      aws_secret_access_key: aws_secret_access_key,
      upload_app_key:        upload_app_key,
      upload_auth_token:     upload_auth_token
    )
    only_if 'test -d /opt/evertrue/upload'
  end
end

%w(generate_random_user_and_pass.sh).each do |file|
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
mailto = 'hai.zhou+upload@evertrue.com'

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
  command '/opt/evertrue/upload/process_uploads.rb'
  user    'root'
  shell   shell
  path    path
  mailto  mailto
end

cron_d 'clean_uploads' do
  minute   15
  hour     0
  command  'find /var/evertrue/uploads/* -mtime +7 -exec /bin/rm {} \;'
  user    'root'
  shell    shell
  path     path
end
