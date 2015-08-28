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

%w(
  pagerduty
  sentry-raven
).each do |pkg|
  gem_package pkg do
    compile_time false
  end
end

case node['platform_family']
when 'debian'
  include_recipe 'apt'
end

include_recipe 'build-essential'

%w(ruby1.9.1 ruby1.9.1-dev).each do |pkg|
  package pkg
end

gem_package 'aws-sdk' do
  version '~> 1.0'
  action :upgrade
end

%w(rubyzip multipart-post).each do |gem_pkg|
  gem_package gem_pkg
end

["#{node['et_upload']['base_dir']}/archive_dir", '/opt/evertrue/scripts'].each do |path|
  directory path do
    owner 'root'
    group 'root'
    recursive true
  end
end

unames_db = data_bag_item('users', 'upload')
unames = unames_db.select { |uname, conf| uname != 'id' && !conf['mock'] && conf['action'] != 'remove' }.keys

Chef::Log.debug("unames_db: #{unames_db.inspect}")
Chef::Log.debug("unames: #{unames}")

s3_creds = data_bag_item(
  'secrets',
  'aws_credentials'
)["Upload-#{node.chef_environment}"]

aws_access_key_id     = s3_creds['access_key_id']
aws_secret_access_key = s3_creds['secret_access_key']

upload_creds = data_bag_item(
  'secrets',
  'api_keys'
)[node.chef_environment]['importer']['upload']

upload_app_key    = upload_creds['app_key']
upload_auth_token = upload_creds['auth_token']

settings = {
  api_url:               node['et_upload']['api_url'],
  unames:                unames,
  aws_access_key_id:     node['et_upload']['aws_access_key_id'] || aws_access_key_id,
  aws_secret_access_key: node['et_upload']['aws_secret_access_key'] || aws_secret_access_key,
  upload_app_key:        node['et_upload']['upload_app_key'] || upload_app_key,
  upload_auth_token:     node['et_upload']['upload_auth_token'] || upload_auth_token,
  upload_dir:            "#{node['et_upload']['base_dir']}/users",
  archive_dir:           "#{node['et_upload']['base_dir']}/archive_dir",
  log:                   '/var/log/process_uploads.log',
  sentry_dsn:            data_bag_item('secrets', 'monitoring')['sentry']['dsn'],
  pagerduty:             data_bag_item('secrets', 'api_keys')['pagerduty']['sftp_uploader'],
  support_email:         node['et_upload']['support_email']
}

logrotate_app 'sftp_uploader' do
  path      '/var/log/process_uploads.log'
  frequency 'daily'
  rotate    10
  create    '644 root root'
end

file '/opt/evertrue/config.yml' do
  content settings.to_yaml
  mode 0600
end

# Delete old files
%w(process_uploads.rb
   generate_random_user_and_pass.sh
   show_uploads.sh).each do |file|
  file "/opt/evertrue/upload/#{file}" do
    action :delete
  end
end

%w(process_uploads
   generate_random_user_and_pass
   show_uploads).each do |file|
  cookbook_file "/opt/evertrue/scripts/#{file}" do
    mode 0755
  end
end

shell  = '/bin/bash'
path   = '/sbin:/bin:/usr/sbin:/usr/bin'
mailto = 'sftp-uploader@evertrue.com'

cron_d 'show_uploads' do
  minute  0
  hour    '*/4'
  command '/opt/evertrue/scripts/show_uploads'
  user    'root'
  shell   shell
  path    path
  mailto  mailto
end

cron_d 'process_uploads' do
  minute  0
  command '/opt/evertrue/scripts/process_uploads'
  user    'root'
  shell   shell
  path    path
  mailto  mailto
end

cron_d 'clean_uploads' do
  minute   15
  hour     0
  command  "find #{node['et_upload']['base_dir']}/archive_dir/* -mtime +7 -exec /bin/rm {} \\;"
  user    'root'
  shell    shell
  path     path
end
