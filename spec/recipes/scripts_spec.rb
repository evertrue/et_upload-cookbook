require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_command('test -d /opt/evertrue/upload').and_return(0)

    ChefSpec::Server.create_data_bag(
      'users',
      'upload' => {
        'id' => 'upload',
        'penncharter4616' => {
          'uid'      => 10_042,
          'keys'     => 'ssh-key-1',
          'contact'  => 'Test User 1',
          'password' => 'password'
        },
        'randolphschool6139' => {
          'uid'      => 10_041,
          'keys'     => 'ssh-key-2',
          'contact'  => 'Test User 2',
          'password' => 'password'
        }
      }
    )
  end

  %w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
    it "creates directory #{path}" do
      expect(chef_run).to create_directory(path).with(
        user: 'root',
        group: 'root'
      )
    end
  end

  %w(provision_user.sh show_uploads.sh process_uploads.sh).each do |file|
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
