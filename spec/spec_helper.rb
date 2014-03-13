require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/server'

RSpec.configure do |config|
  config.log_level = :fatal
end

def create_cron_d(name)
  ChefSpec::Matchers::ResourceMatcher.new(:cron_d, :create, name)
end

def delete_cron_d(name)
  ChefSpec::Matchers::ResourceMatcher.new(:cron_d, :delete, name)
end

ChefSpec::Server.create_client('et_upload_spec', admin: true)
