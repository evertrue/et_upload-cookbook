require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  users = data_bag('users')

  before do
    setup_environment
  end

  users['upload'].each do |uname, u|
    next if uname == 'id'

    u['home'] = "/home/#{uname}"
    u['gid']  = 'uploadonly'
    evertrue_gid = 'evertrue'

    it "creates user #{uname}" do
      expect(chef_run).to create_user(uname).with(
        uid:      u['uid'],
        gid:      u['gid'],
        comment:  u['comment'],
        password: u['password'],
        home:     u['home']
      )
    end

    it "sets #{uname} home folder mode and ownership" do
      expect(chef_run).to create_directory(u['home']).with(
        user:  'root',
        group: u['gid'],
        mode:  '0755'
      )
    end

    mode = (uname == 'trial-user') ? '0300' : '0700'
    it "creates #{dir}" do
      expect(chef_run).to create_directory(dir).with(
        user:  uname,
        group: u['gid'],
        mode:  mode
      )
    end

    ["#{u['home']}/uploads", "#{u['home']}/exports"].each do |dir|
      it "creates #{dir}" do
        expect(chef_run).to create_directory(dir).with(
          user:  uname,
          group: evertrue_gid,
          mode:  770
        )
      end
    end

    it "creates #{uname}'s authorized_keys" do
      auth_keys_path = "#{u['home']}/.ssh/authorized_keys"

      expect(chef_run).to create_template(auth_keys_path).with(
        user:  uname,
        group: u['gid'],
        mode:  '0600'
      )
      expect(chef_run).to render_file(auth_keys_path).with_content(u['keys'])
    end
  end
end
