require 'helper'
require 'fileutils'

describe Scide::Config do

  it "should use the default config file if not given" do
    conf = Scide::Config.new
    conf.file.should == Scide::Config::DEFAULT_CONFIG_FILE
  end

  it "should use the given config file" do
    conf = Scide::Config.new '/tmp/fubar'
    conf.file.should == '/tmp/fubar'
  end

  it "should be empty when not loaded" do
    conf = Scide::Config.new
    conf.screen.should be_nil
    conf.global.should be_nil
    conf.projects.should be_nil
  end

  it "should be filled when loaded" do
    file = File.join File.dirname(__FILE__), 'results', 'config1.yml'
    conf = Scide::Config.new file
    make_load conf
    conf.screen.should be_a(HashWithIndifferentAccess)
    conf.global.should be_a(Scide::Global)
    conf.projects.should be_a(HashWithIndifferentAccess)
    conf.projects[:project1].should be_a(Scide::Project)
  end

  it "should exit with status 10 when the config file does not exist" do
    bad_file = "/tmp/IHateYouIfYouAddedThisFileJustToMakeMyTestFail"
    lambda{ make_load Scide::Config.new(bad_file) }.should raise_error(SystemExit){ |err| err.status == 10 }
  end

  it "should exit with status 11 if the config file is not readable" do
    unreadable_file = Tempfile.new 'scide-unreadable'
    FileUtils.chmod 0200, unreadable_file.path
    lambda{ make_load Scide::Config.new(unreadable_file.path) }.should raise_error(SystemExit){ |err| err.status == 11 }
    unreadable_file.unlink
  end

  it "should exit with status 1 if the config file cannot be read" do
    file = File.join File.dirname(__FILE__), 'results', 'config1.yml'
    conf = Scide::Config.new file
    conf.stub!(:load_config){ raise 'bug' }
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 1 }
  end

  it "should exit with status 12 if the config file is not valid YAML" do
    file = File.join File.dirname(__FILE__), 'results', 'malformed_config.yml'
    conf = Scide::Config.new file
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 12 }
  end

  it "should exit with status 13 if the configuration is not a hash" do
    conf = Scide::Config.new
    conf.stub!(:load_config){ "- 'a'\n- 'b'" }
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 13 }
  end

  it "should exit with status 13 if the screen configuration is not a hash" do
    conf = Scide::Config.new
    conf.stub!(:load_config){ "screen:\n- 'a'\n- 'b'" }
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 13 }
  end

  it "should exit with status 13 if the projects configuration is not a hash" do
    conf = Scide::Config.new
    conf.stub!(:load_config){ "projects:\n- 'a'\n- 'b'" }
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 13 }
  end

  it "should exit with status 13 if the configuration is otherwise invalid" do
    conf = Scide::Config.new
    conf.stub!(:load_config){ "global:\n  a: true\nprojects:\n  a:\n    - 'a'\n    - 'b'" }
    lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == 13 }
  end

  private

  def make_load conf
    SpecHelper.silence{ conf.load! }
  end
end
