require 'helper'

describe Scide::Window do

  before :each do
    @options = { :a => 1, :b => true }
    @project = double('project')
    @project.stub(:options){ @options }
  end

  describe "String Initialization" do
    it "should take the given name" do
      win = Scide::Window.new @project, 'fubar'
      win.name.should == 'fubar'
    end

    it "should create the correct command" do
      win = Scide::Window.new @project, 'fubar EDIT'
      win.command.should be_a_kind_of(Scide::Commands::Edit)
    end

    it "should be initializable with a name and a command with no contents" do
      lambda{ Scide::Window.new @project, 'fubar EDIT' }.should_not raise_error(ArgumentError)
    end

    it "should be initializable with a name and a command with contents" do
      lambda{ Scide::Window.new @project, 'fubar TAIL file.txt' }.should_not raise_error(ArgumentError)
    end

    it "should raise an error when initialized without a name" do
      lambda{ Scide::Window.new @project, '   ' }.should raise_error(ArgumentError)
    end

    it "should raise an error for unknown commands" do
      lambda{ Scide::Window.new @project, 'fubar EDT' }.should raise_error(ArgumentError)
    end
  end

  describe "Hash Initialization" do
    it "should take the given name" do
      win = Scide::Window.new @project, :name => 'fubar'
      win.name.should == 'fubar'
    end

    it "should create the correct command" do
      win = Scide::Window.new @project, :name => 'fubar', :command => 'EDIT'
      win.command.should be_a_kind_of(Scide::Commands::Edit)
    end

    it "should be initializable with a name and a command with no contents" do
      lambda{ Scide::Window.new @project, :name => 'fubar', :command => 'EDIT' }.should_not raise_error(ArgumentError)
    end

    it "should be initializable with a name and a command with contents" do
      lambda{ Scide::Window.new @project, :name => 'fubar', :command => 'EDIT', :contents => 'file.txt' }.should_not raise_error(ArgumentError)
    end

    it "should raise an error when initialized without a name" do
      lambda{ Scide::Window.new @project, :fubar => true }.should raise_error(ArgumentError)
    end

    it "should raise an error for unknown commands" do
      lambda{ Scide::Window.new @project, :name => 'fubar', :command => 'EDT' }.should raise_error(ArgumentError)
    end

    describe "String Option" do
      
      it "should take the given name" do
        win = Scide::Window.new @project, :string => 'fubar'
        win.name.should == 'fubar'
      end

      it "should create the correct command" do
        win = Scide::Window.new @project, :string => 'fubar EDIT'
        win.command.should be_a_kind_of(Scide::Commands::Edit)
      end

      it "should be initializable with a name and a command with no contents" do
        lambda{ Scide::Window.new @project, :string => 'fubar EDIT' }.should_not raise_error(ArgumentError)
      end

      it "should be initializable with a name and a command with contents" do
        lambda{ Scide::Window.new @project, :string => 'fubar EDIT file.txt' }.should_not raise_error(ArgumentError)
      end

      it "should raise an error when initialized without a name" do
        lambda{ Scide::Window.new @project, :string => '   ' }.should raise_error(ArgumentError)
      end

      it "should raise an error for unknown commands" do
        lambda{ Scide::Window.new @project, :string => 'fubar EDT' }.should raise_error(ArgumentError)
      end
    end
  end

  it "should raise an error when type of contents is unknown" do
    lambda{ Scide::Window.new(@project, []) }.should raise_error(ArgumentError)
  end

  it "should duplicate project options" do
    @project.should_receive :options
    win = Scide::Window.new @project, 'fubar'
    win.options.should == @options
    win.options.should_not equal(@options)
  end

  it "should merge its options to project options" do
    window_options = { :b => false, :c => 'foo' }
    @project.should_receive :options
    win = Scide::Window.new @project, :name => 'fubar', :options => window_options
    win.options.should == @options.merge(window_options)
  end

  it "should generate a GNU Screen window" do
    # without a command, hash initialization
    win = Scide::Window.new @project, :name => 'fubar'
    win.to_screen(0).should == 'screen -t fubar 0'
    # with a command, string initialization
    win = Scide::Window.new @project, 'fubar EDIT file.txt'
    win.to_screen(0).should == %|screen -t fubar 0\n#{win.command.to_screen}|
  end
end
