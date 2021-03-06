#
# Cookbook Name:: et_upload
# Recipe:: default
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

include_recipe 'storage'

if node['storage']['ephemeral_mounts'] && !node['storage']['ephemeral_mounts'].empty?
    node.set['et_upload']['base_dir'] =
          "#{node['storage']['ephemeral_mounts'].first}/evertrue"
else
    node.set['et_upload']['base_dir'] = '/opt/evertrue'
end

include_recipe 'openssh::default'
include_recipe 'et_upload::scripts'
include_recipe 'et_upload::users'

sudo 'converge_chef' do
  group 'evertrue'
  nopasswd true
  commands(
    [
      '/usr/sbin/service chef-client restart',
      '/usr/bin/chef-client'
    ]
  )
end
