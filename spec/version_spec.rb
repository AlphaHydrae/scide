require 'helper'

describe 'Version' do
  subject{ Scide::VERSION }
  it{ should eq(File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))) }
end
