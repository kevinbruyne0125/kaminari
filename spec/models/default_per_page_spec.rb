require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'default per_page' do
  subject { User.page 0 }

  context 'by default' do
    its(:limit_value) { should == 25 }
  end

  context 'when explicitly set via paginates_per' do
    before { User.paginates_per 1326 }
    its(:limit_value) { should == 1326 }
    after { User.paginates_per nil }
  end
end
