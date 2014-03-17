require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  users = {
    'upload' => {
      'id' => 'upload',
      'penncharter4616' => {
        'uid'      => 10_042,
        'ssh_keys'     => 'ssh-key-1',
        'comment'  => 'Test User 1',
        'password' => 'password'
      },
      'randolphschool6139' => {
        'uid'      => 10_041,
        'ssh_keys'     => 'ssh-key-2',
        'comment'  => 'Test User 2',
        'password' => 'password'
      }
    }
  }

  before do
    stub_command('test -d /opt/evertrue/upload').and_return(0)

    ChefSpec::Server.create_data_bag('users', users)
  end

  users['upload'].each do |uname, u|
    if uname != 'id'
      u['home'] = "/home/#{uname}"
      u['gid']  = 'uploadonly'

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

      ["#{u['home']}/.ssh", "#{u['home']}/uploads"].each do |dir|
        it "creates #{dir}" do
          expect(chef_run).to create_directory(dir).with(
            user:  uname,
            group: u['gid'],
            mode:  '0700'
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
end
