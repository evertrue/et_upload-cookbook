require 'spec_helper'

describe 'et_upload::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_command('test -d /opt/evertrue/upload').and_return(0)
  end

  # it 'includes openssh::default' do
  #   expect(chef_run).to include_recipe('openssh::default')
  # end
end
