require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/server'
require 'json'

RSpec.configure do |config|
  config.log_level = :fatal
end

def create_cron_d(name)
  ChefSpec::Matchers::ResourceMatcher.new(:cron_d, :create, name)
end

def delete_cron_d(name)
  ChefSpec::Matchers::ResourceMatcher.new(:cron_d, :delete, name)
end

def users_databag_item
  upload_users_file = File.open('test/integration/default/data_bags/users/upload.json').read
  JSON.parse(upload_users_file)
end

ChefSpec::Server.create_client('et_upload_spec', admin: true)
