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

def data_bag_item(bag, item)
  JSON.parse(
    File.read("test/integration/default/data_bags/#{bag}/#{item}.json")
  )
end

ChefSpec::Server.create_client('et_upload_spec', admin: true)
