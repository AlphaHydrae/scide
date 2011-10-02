require 'helper'

describe Scide::Screen do

  before :each do
    @project = double('project')
    @project.stub(:path){ '/tmp' }
    @project.stub(:to_screen){ 'fubar' }
  end

  it "should generate a command to run screen at the given project's path" do
    screen = Scide::Screen.new(@project, {})
    @project.should_receive :path
    screen.to_command('fubar').should == 'cd /tmp && screen -c fubar'
  end

  it "should generate a command to run screen with the given options" do
    screen = Scide::Screen.new @project, :binary => '/usr/bin/screen', :args => '-U'
    @project.should_receive :path
    screen.to_command('fubar').should == 'cd /tmp && /usr/bin/screen -U -c fubar'
  end

  it "should generate a screen configuration file" do
    global = double('global')
    global.stub(:path){ nil }
    global.stub(:options){ {} }
    contents = {
      :windows => [
        'window1 EDIT',
        { :name => 'window2', :command => 'SHOW', :contents => 'ssh example.com' },
        'window3 TAIL file.txt',
        { :string => 'window4 RUN ls -la' },
        'window5'
      ]
    }
    project = Scide::Project.new(global, 'fubar', contents)
    screen = Scide::Screen.new project, :hardstatus => 'dummy'
    screen.to_s.should == SpecHelper.result(:screen1)
  end

  it "should use the default hardstatus line if not given" do
    screen = Scide::Screen.new(@project, {})
    screen.hardstatus.should == Scide::Screen::DEFAULT_HARDSTATUS
  end

  it "should use the given hardstatus line" do
    screen = Scide::Screen.new @project, :hardstatus => 'fubar'
    screen.hardstatus.should == 'fubar'
  end

  it "should use the default binary if not given" do
    screen = Scide::Screen.new(@project, {})
    screen.binary.should == 'screen'
  end

  it "should use the given binary" do
    screen = Scide::Screen.new @project, :binary => '/usr/bin/screen'
    screen.binary.should == '/usr/bin/screen'
  end

  it "should use the given args" do
    screen = Scide::Screen.new @project, :args => '-U'
    screen.args.should == '-U'
  end

  it "should duplicate the given options" do
    options = { :a => 1, :b => true }
    screen = Scide::Screen.new @project, options
    screen.options.should == options
    screen.options.should_not equal(options)
  end

  it "should exit with status 4 if the screen binary is not found" do
    bad_binary = "IHateYouIfYouAddedThisBinaryJustToMakeMyTestFail"
    lambda{ SpecHelper.silence{ Scide::Screen.new(@project, :binary => bad_binary).check_binary } }.should raise_error(SystemExit){ |err| err.status.should == 4 }
  end

  it "should raise an error if the options are not nil and not a hash" do
    [ '   ', [] ].each do |not_hash|
      lambda{ Scide::Screen.new @project, not_hash }.should raise_error(ArgumentError)
    end
  end
end
