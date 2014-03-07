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

# Steps to set up:
# 3. Install rssh
# 4. Configure RSSH
# 5. Set up chroot jail
# 6. Copy necessary system files to chroot jail (users will not read things outside jail)
# 7. Set up users

include_recipe 'et_upload::scripts'
