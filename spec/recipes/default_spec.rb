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

  it 'includes openssh::default' do
    expect(chef_run).to include_recipe('openssh::default')
  end

  it 'includes et_upload::scripts' do
    expect(chef_run).to include_recipe('et_upload::scripts')
  end

  it 'includes et_upload::users' do
    expect(chef_run).to include_recipe('et_upload::users')
  end
end
