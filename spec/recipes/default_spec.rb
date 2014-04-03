require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_command('test -d /opt/evertrue/upload').and_return(0)

    upload_users = {}
    upload_users['upload'] = data_bag_item('users', 'upload')
    ChefSpec::Server.create_data_bag('users', upload_users)
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
