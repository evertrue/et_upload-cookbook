cookbook_file "#{Chef::Config[:file_cache_path]}/id_rsa" do
  source 'id_rsa'
  mode 0600
end

cookbook_file "#{Chef::Config[:file_cache_path]}/test_gifts_file.gifts.csv" do
  source 'test_gifts_file.gifts.csv'
end

cookbook_file "#{Chef::Config[:file_cache_path]}/test_contacts_file.csv" do
  source 'test_contacts_file.csv'
end

file "#{Chef::Config[:file_cache_path]}/sftp_batch_command_gifts" do
  content "put #{Chef::Config[:file_cache_path]}/test_gifts_file.gifts.csv uploads/test_gifts_file.gifts.csv\nexit\n"
end

file "#{Chef::Config[:file_cache_path]}/sftp_batch_command_contacts" do
  content "put #{Chef::Config[:file_cache_path]}/test_contacts_file.csv uploads/test_contacts_file.csv\nexit\n"
end

# put /tmp/kitchen/cache/test_gifts_files.csv uploads/test_gifts_file.gifts.csv
