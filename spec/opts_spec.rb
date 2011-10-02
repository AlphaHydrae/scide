require 'helper'

describe Scide::Opts do

  before :each do
    @opts = Scide::Opts.new
  end
  
  it "should add the help flag" do
    [ '-h', '--help' ].each do |flag|
      lambda{ parse!([flag]) }.should raise_error(SystemExit){ |err| err.status.should == 0 }
    end
  end

  it "should add the usage flag" do
    [ '-u', '--usage' ].each do |flag|
      lambda{ parse!([flag]) }.should raise_error(SystemExit){ |err| err.status.should == 0 }
    end
  end

  it "should add the version flag" do
    expected_version = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read
    lambda{ parse!([ '--version' ]) }.should raise_error(SystemExit){ |err| err.status.should == 0 }
  end

  it "should add the dry run flag" do
    parse!([ '--dry-run' ])
    @opts.funnel[:'dry-run'].should == true
  end

  it "should exit with status 2 for unknown arguments" do
    [ '-x', '--fubar', '-4' ].each do |unknown|
      lambda{ parse!([unknown]) }.should raise_error(SystemExit){ |err| err.status.should == 2 }
    end
  end

  private

  def parse! args
    silence_stream(STDOUT){ silence_stream(STDERR){ @opts.parse! args } }
  end
end
