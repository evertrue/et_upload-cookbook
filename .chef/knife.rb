# Used by knife-solo_data_bag to generate dummy encrypted data bags
current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
cookbook_path              ["#{ENV['CHEF_REPO']}/cookbooks"]
client_key                "#{ENV['KNIFE_CLIENT_KEY']}"
node_name                 'solo'
data_bag_path             "#{current_dir}/../test/integration/default/data_bags"
encrypted_data_bag_secret "#{current_dir}/../test/integration/default/encrypted_data_bag_secret"
