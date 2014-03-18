require 'spec_helper'

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

  %w(show_uploads process_uploads).each do |script|
    describe file("#{scripts_path}/#{script}.sh") do
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe file("/etc/cron.d/#{script}") do
      its(:content) { should include shell }
      its(:content) { should include path }
      its(:content) { should include mailto }

      cron_hour = '*'
      cron_hour = '*/4' if script == 'show_uploads'

      its(:content) do
        should include "0 #{cron_hour} * * * root #{scripts_path}/#{script}.sh"
      end
    end
  end

  describe file('/etc/cron.d/clean_uploads') do
    its(:content) { should include shell }
    its(:content) { should include path }
    its(:content) { should include mailto }

    its(:content) do
      should include '15 0 * * * root /bin/find /var/evertrue/uploads/* -mtime +7 -exec /bin/rm {} \;'
    end
  end
end
