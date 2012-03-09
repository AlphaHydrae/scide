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

  [ true, false ].each do |exit_on_fail|
    describe "Errors with exit on fail #{exit_on_fail}" do
      before :each do
        Scide.exit_on_fail = exit_on_fail
      end

      after :each do
        Scide.exit_on_fail = true
      end
      
      it SpecHelper.should_fail(exit_on_fail, :config_not_found, "when the config file does not exist") do
        bad_file = "/tmp/IHateYouIfYouAddedThisFileJustToMakeMyTestFail"
        conf = Scide::Config.new bad_file
        load_should_fail(conf, :config_not_found)
      end

      it SpecHelper.should_fail(exit_on_fail, :config_not_readable, "if the config file is not readable") do
        unreadable_file = Tempfile.new 'scide-unreadable'
        FileUtils.chmod 0200, unreadable_file.path
        conf = Scide::Config.new unreadable_file.path
        load_should_fail(conf, :config_not_readable)
        unreadable_file.unlink
      end

      it SpecHelper.should_fail(exit_on_fail, :unexpected, "if the config file cannot be read") do
        file = File.join File.dirname(__FILE__), 'results', 'config1.yml'
        conf = Scide::Config.new file
        conf.stub!(:load_config){ raise 'bug' }
        load_should_fail(conf, :unexpected)
      end

      it SpecHelper.should_fail(exit_on_fail, :malformed_config, "if the config file is not valid YAML") do
        file = File.join File.dirname(__FILE__), 'results', 'malformed_config.yml'
        conf = Scide::Config.new file
        load_should_fail(conf, :malformed_config)
      end

      it SpecHelper.should_fail(exit_on_fail, :invalid_config, "if the configuration is not a hash") do
        conf = Scide::Config.new
        conf.stub!(:check_config){}
        conf.stub!(:load_config){ "- 'a'\n- 'b'" }
        load_should_fail(conf, :invalid_config)
      end

      it SpecHelper.should_fail(exit_on_fail, :invalid_config, "if the screen configuration is not a hash") do
        conf = Scide::Config.new
        conf.stub!(:check_config){}
        conf.stub!(:load_config){ "screen:\n- 'a'\n- 'b'" }
        load_should_fail(conf, :invalid_config)
      end

      it SpecHelper.should_fail(exit_on_fail, :invalid_config, "if the projects configuration is not a hash") do
        conf = Scide::Config.new
        conf.stub!(:check_config){}
        conf.stub!(:load_config){ "projects:\n- 'a'\n- 'b'" }
        load_should_fail(conf, :invalid_config)
      end

      it SpecHelper.should_fail(exit_on_fail, :invalid_config, "if the configuration is otherwise invalid") do
        conf = Scide::Config.new
        conf.stub!(:check_config){}
        conf.stub!(:load_config){ "global:\n  a: true\nprojects:\n  a:\n    - 'a'\n    - 'b'" }
        load_should_fail(conf, :invalid_config)
      end
    end
  end

  private

  def make_load conf
    SpecHelper.silence{ conf.load! }
  end

  def load_should_fail conf, condition
    if Scide.exit_on_fail
      lambda{ make_load conf }.should raise_error(SystemExit){ |err| err.status.should == Scide::EXIT[condition] }
    else
      lambda{ make_load conf }.should raise_error(Scide::Error){ |err| err.condition.should == condition }
    end
  end
end
