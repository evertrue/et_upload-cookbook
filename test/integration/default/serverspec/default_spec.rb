require 'spec_helper'

upload_users_file = File.open('/tmp/kitchen/data_bags/users/upload.json').read
upload_users = JSON.parse(upload_users_file).select { |uname| uname != 'id' }

describe 'SSH Service' do
  %w(22 43827).each do |port|
    describe port(port) do
      it { should be_listening }
    end
  end

  describe service('ssh') do
    it { should be_running }
    it { should be_enabled }
  end

  describe file('/etc/ssh/sshd_config') do
    its(:content) { should include 'PermitRootLogin no' }
    its(:content) { should include 'PasswordAuthentication yes' }
    its(:content) { should include 'sftp /usr/lib/sftp-server' }
    its(:content) { should include 'ForceCommand internal-sftp' }
  end
end

describe 'Upload Scripts' do
  %w(ruby1.9.1 ruby1.9.1-dev).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  %w(aws-sdk rubyzip multipart-post).each do |pkg_gem|
    describe package(pkg_gem) do
      it { should be_installed.by('gem') }
    end
  end

  %w(/opt/evertrue/upload /var/evertrue/uploads).each do |path|
    describe file(path) do
      it { should be_directory }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end

  scripts_path = '/opt/evertrue/upload'
  shell        = '/bin/bash'
  path         = '/sbin:/bin:/usr/sbin:/usr/bin'
  mailto       = 'hai.zhou+upload@evertrue.com'

  %w(show_uploads.sh process_uploads.rb).each do |script|
    describe file("#{scripts_path}/#{script}") do
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }

      upload_users.keys.each do |uname|
        its(:content) { should include uname }
      end
    end

    describe file("/etc/cron.d/#{script}") do
      its(:content) { should include shell }
      its(:content) { should include path }
      its(:content) { should include mailto }

      cron_hour = '*'
      cron_hour = '*/4' if script == 'show_uploads'

      its(:content) do
        should include "0 #{cron_hour} * * * root #{scripts_path}/#{script}"
      end
    end
  end

  describe file("#{scripts_path}/process_uploads.rb") do
    its(:content) do
      should include 'UPLOAD_TEST_KEY'
      should include 'UPLOAD_TEST_SECRET'
    end
  end

  describe file('/etc/cron.d/clean_uploads') do
    its(:content) { should include shell }
    its(:content) { should include path }

    its(:content) do
      should include '15 0 * * * root find /var/evertrue/uploads/* -mtime +7 -exec /bin/rm {} \;'
    end
  end
end

describe 'Upload users' do
  describe group('uploadonly') do
    it { should exist }
  end

  upload_users.each do |uname, u|
    u['home'] = "/home/#{uname}"
    u['gid'] = 'uploadonly'

    describe user(uname) do
      it { should exist }
      it { should belong_to_group 'uploadonly' }
      it { should have_uid u['uid'] }
      it { should have_home_directory u['home'] }
      it { should have_login_shell '/bin/bash' }

      u['ssh_keys'].each do |ssh_key|
        it { should have_authorized_key ssh_key }
      end
    end

    describe file(u['home']) do
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into u['gid'] }
    end

    ["#{u['home']}/.ssh", "#{u['home']}/uploads"].each do |dir|
      mode = (uname == 'trial-user' && dir == "#{u['home']}/uploads") ? 300 : 700

      describe file(dir) do
        it { should be_directory }
        it { should be_mode mode }
        it { should be_owned_by uname }
        it { should be_grouped_into u['gid'] }
      end
    end

    if u['ssh_keys']
      describe file("#{u['home']}/.ssh/authorized_keys") do
        it { should be_mode 600 }
        it { should be_owned_by uname }
        it { should be_grouped_into u['gid'] }
      end
    end
  end
end
