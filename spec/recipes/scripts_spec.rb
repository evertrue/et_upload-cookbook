require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_command('test -d /opt/evertrue/upload').and_return(0)

    upload_users = {}
    upload_users['upload'] = users_databag_item
    ChefSpec::Server.create_data_bag('users', upload_users)
  end

  %w(ruby1.9.1 ruby1.9.1-dev).each do |pkg|
    it "installs #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end
  end

  %w(aws-sdk rubyzip multipart-post).each do |pkg_gem|
    it "installs RubyGem #{pkg_gem}" do
      expect(chef_run).to install_gem_package(pkg_gem)
    end
  end

  %w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
    it "creates directory #{path}" do
      expect(chef_run).to create_directory(path).with(
        user: 'root',
        group: 'root'
      )
    end
  end

  %w(show_uploads.sh process_uploads.rb).each do |file|
    it "creates file #{file}.sh from template" do
      expect(chef_run).to create_template("/opt/evertrue/upload/#{file}").with(
        source: "#{file}.erb",
        user: 'root',
        group: 'root',
        mode: '0755'
      )
    end
  end

  %w(generate_random_user_and_pass.sh).each do |file|
    it "creates file #{file}" do
      expect(chef_run).to create_cookbook_file(file).with(
        user: 'root',
        group: 'root',
        mode: '0755'
      )
    end
  end

  %w(show_uploads process_uploads clean_uploads).each do |cronjob|
    it "installs #{cronjob} in cron.d" do
      expect(chef_run).to create_cron_d(cronjob)
    end
  end
end
