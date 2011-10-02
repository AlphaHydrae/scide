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
end
