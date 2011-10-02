require 'helper'

describe 'Scide::VERSION' do

  it "should be the correct version" do
    Scide::VERSION.should == File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read
  end
end
