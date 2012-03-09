require 'helper'

describe Scide do

  before :each do
    Scide.exit_on_fail = true
  end

  after :each do
    Scide.exit_on_fail = true
  end
  
  it "should have the correct version" do
    Scide::VERSION.should == File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read
  end

  it "should exit on fail by default" do
    lambda{ SpecHelper.silence{ Scide.fail nil, 'fubar' } }.should raise_error(SystemExit)
  end

  it "should exit with the correct status code" do
    Scide::EXIT.each_pair do |condition,code|
      lambda{ SpecHelper.silence{ Scide.fail condition, 'fubar' } }.should raise_error(SystemExit){ |err| err.status.should == code }
    end
  end

  it "should raise an error on fail if configured to do so" do
    Scide.exit_on_fail = false
    lambda{ Scide.fail nil, 'fubar' }.should raise_error(Scide::Error)
  end

  it "should raise an error with the correct condition" do
    Scide.exit_on_fail = false
    Scide::EXIT.each_pair do |condition,code|
      lambda{ Scide.fail condition, 'fubar' }.should raise_error(Scide::Error){ |err| err.condition.should == condition }
    end
  end
end
