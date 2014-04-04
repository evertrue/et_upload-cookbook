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
  secrets_encrypted_data_bag_item('aws_credentials')
  secrets_encrypted_data_bag_item('api_keys')
end

def data_bag(name)
  data_bag = {}

  Dir["test/integration/default/data_bags/#{name}/*.json"].map do |f|
    data_bag_item = File.basename(f, '.json')
    data_bag[data_bag_item] = JSON.parse File.read(f)
  end

  data_bag
end

def secrets_encrypted_data_bag_item(item)
  contents = {}

  if item == 'aws_credentials'
    contents = {
      'id' => 'aws_credentials',
      'Upload-_default' => {
        'access_key_id' => 'UPLOAD_TEST_KEY',
        'secret_access_key' => 'UPLOAD_TEST_SECRET'
      }
    }
  elsif item == 'api_keys'
    contents = {
      '_default' => {
        'importer' => {
          'upload' => {
            'app_key'    => 'abc123',
            'auth_token' => 'secret'
          }
        }
      }
    }
  else
    fail 'Invalid data bag item specified.'
  end

  Chef::EncryptedDataBagItem.stub(:load)
    .with('secrets', item)
    .and_return(contents)
end
