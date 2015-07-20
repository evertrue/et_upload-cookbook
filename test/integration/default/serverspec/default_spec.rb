require 'spec_helper'
require 'json'

upload_users_file = File.open('/tmp/kitchen/data_bags/users/upload.json').read
upload_users = JSON.parse(upload_users_file)
  .select { |uname, conf| uname != 'id' && !conf['mock'] }

describe 'SSH Service' do
  %w(22 43827).each do |port|
    describe port(port) do
      it { is_expected.to be_listening }
    end
  end

  describe service('ssh') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe file('/etc/ssh/sshd_config') do
    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'PermitRootLogin no' }
    end

    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'PasswordAuthentication yes' }
    end

    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'sftp /usr/lib/sftp-server' }
    end

    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'ForceCommand internal-sftp' }
    end
  end
end

describe 'Upload Scripts' do
  %w(ruby1.9.1 ruby1.9.1-dev).each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  %w(aws-sdk rubyzip multipart-post).each do |pkg_gem|
    describe package(pkg_gem) do
      it { is_expected.to be_installed.by('gem') }
    end
  end

  %w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
    describe file(path) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end

  scripts_path = '/opt/evertrue/upload'
  shell        = '/bin/bash'
  path         = '/sbin:/bin:/usr/sbin:/usr/bin'
  mailto       = 'hai.zhou+upload@evertrue.com'

  describe file('/opt/evertrue/config.yml') do
    it { is_expected.to be_mode 600 }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }

    upload_users.each do |uname, _u|
      describe '#content' do
        subject { super().content }
        it { is_expected.to include uname }
      end
    end
  end

  %w(show_uploads process_uploads).each do |script|
    describe file("#{scripts_path}/#{script}") do
      it { is_expected.to be_mode 755 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    cronjob = File.basename(script, File.extname(script))

    describe file("/etc/cron.d/#{cronjob}") do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include shell }
      end

      describe '#content' do
        subject { super().content }
        it { is_expected.to include path }
      end

      describe '#content' do
        subject { super().content }
        it { is_expected.to include mailto }
      end

      cron_hour = '*'
      cron_hour = '*/4' if script == 'show_uploads'

      describe '#content' do
        subject { super().content }
        it { is_expected.to include "0 #{cron_hour} * * * root #{scripts_path}/#{script}" }
      end
    end
  end

  describe file('/etc/cron.d/clean_uploads') do
    describe '#content' do
      subject { super().content }
      it { is_expected.to include shell }
    end

    describe '#content' do
      subject { super().content }
      it { is_expected.to include path }
    end

    describe '#content' do
      subject { super().content }
      it do
        is_expected.to include(
          '15 0 * * * root find /var/evertrue/uploads/* -mtime +7 -exec /bin/rm {} \;'
        )
      end
    end
  end

  %w(process_uploads.rb generate_random_user_and_pass.sh show_uploads.sh).each do |script|
    describe file("/opt/evertrue/upload/#{script}") do
      it { is_expected.to_not be_file }
    end
  end
end

describe 'Upload users' do
  describe group('uploadonly') do
    it { is_expected.to exist }
  end

  upload_users.each do |uname, u|
    home = "/home/#{uname}"
    gid = 'uploadonly'

    describe user(uname) do
      it { is_expected.to exist }
      it { is_expected.to belong_to_group 'uploadonly' }
      it { is_expected.to have_uid u['uid'] }
      it { is_expected.to have_home_directory home }
      it { is_expected.to have_login_shell '/bin/bash' }

      u['ssh_keys'].each do |ssh_key|
        it { is_expected.to have_authorized_key ssh_key }
      end
    end

    describe file(home) do
      it { is_expected.to be_directory }
      it { is_expected.to be_mode 755 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into gid }
    end

    if u['ssh_keys']
      describe file("#{home}/.ssh/authorized_keys") do
        it { is_expected.to be_mode 600 }
        it { is_expected.to be_owned_by uname }
        it { is_expected.to be_grouped_into gid }
      end
    end

    ["#{home}/.ssh", "#{home}/uploads"].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_mode 700 }
        it { is_expected.to be_owned_by uname }
        it { is_expected.to be_grouped_into gid }
      end
    end
  end
end

describe 'Process uploads' do
  describe command('sftp -P 43827 -b /tmp/kitchen/cache/sftp_batch_command -o StrictHostKeyChecking=no -i /tmp/kitchen/cache/id_rsa amherst4451@localhost') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/opt/evertrue/upload/process_uploads') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match 'sent file /home/amherst4451/uploads/test_gifts_files.csv for processing' }
    upload_users.each { |uname, _u| its(:stdout) { should match "Uploaded data from: #{uname}" } }
  end
end
