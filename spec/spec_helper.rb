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

def setup_environment
  stub_command('test -d /opt/evertrue/upload').and_return(0)

  ChefSpec::Server.create_data_bag('users', data_bag('users'))
end

def data_bag(name)
  data_bag = {}

  Dir["test/integration/default/data_bags/#{name}/*.json"].map do |f|
    data_bag_item = File.basename(f, '.json')
    data_bag[data_bag_item] = JSON.parse File.read(f)
  end

  data_bag
end

