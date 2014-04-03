require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    setup_environment
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
