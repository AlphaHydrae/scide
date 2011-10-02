require 'helper'

describe Scide::Global do

  it "should take the given path if absolute" do
    global = Scide::Global.new :path => '/tmp'
    global.path.should == '/tmp'
  end

  it "should expand the given path from the home directory if relative" do
    global = Scide::Global.new :path => 'fubar'
    global.path.should == File.join(File.expand_path('~'), 'fubar')
  end

  it "should use the home directory if no path is given" do
    global = Scide::Global.new({})
    global.path.should == File.expand_path('~')
  end

  it "should duplicate the given options" do
    options = { :a => 1, :b => true }
    global = Scide::Global.new :options => options
    global.options.should == options
    global.options.should_not equal(options)
  end

  it "should raise an error if the contents are not a hash" do
    [ nil, '   ', [] ].each do |not_hash|
      lambda{ Scide::Global.new not_hash }.should raise_error(ArgumentError)
    end
  end

  it "should raise an error if its options are not nil and not a hash" do
    [ '   ', [] ].each do |not_hash|
      lambda{ Scide::Global.new :options => not_hash }.should raise_error(ArgumentError)
    end
  end
end
