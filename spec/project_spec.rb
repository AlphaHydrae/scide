require 'helper'

describe Scide::Project do
  
  before :each do
    @path = '/tmp'
    @options = { :a => 1, :b => true }
    @global = double('global')
    @global.stub(:path){ @path }
    @global.stub(:options){ @options }
  end

  it "should add the project key to the global path by default" do
    pro = Scide::Project.new @global, 'fubar', :windows => []
    pro.path.should == File.join(@path, pro.key)
  end

  it "should add its path to the global path if relative" do
    pro = Scide::Project.new @global, 'fubar', :windows => [], :path => 'foo'
    pro.path.should == File.join(@path, 'foo')
  end

  it "should use its path if absolute" do
    pro = Scide::Project.new @global, 'fubar', :windows => [], :path => '/foo'
    pro.path.should == '/foo'
  end

  it "should use its path if there is no global path" do
    global_no_path = double('global')
    global_no_path.stub(:path){ nil }
    global_no_path.stub(:options){ { :a => 1, :b => true } }
    pro = Scide::Project.new global_no_path, 'fubar', :windows => [], :path => '/foo'
    pro.path.should == '/foo'
  end

  it "should expand its path if relative" do
    global_relative = double('global')
    global_relative.stub(:path){ nil }
    global_relative.stub(:options){ { :a => 1, :b => true } }
    pro = Scide::Project.new global_relative, 'fubar', :windows => []
    pro.path.should == File.join(File.expand_path('~'), 'fubar')
  end

  it "should duplicate global options" do
    @global.should_receive :path
    @global.should_receive :options
    pro = Scide::Project.new @global, 'fubar', :windows => []
    pro.options.should_not equal(@options)
  end

  it "should add name and path to options" do
    additional_options = { :name => 'fubar', :path => File.join(@path, 'fubar') }
    pro = Scide::Project.new @global, 'fubar', :windows => []
    pro.options.should == @options.merge(additional_options)
  end

  it "should override global name and path" do
    global_with_name_and_path = double('global')
    global_with_name_and_path.stub(:path){ @path }
    global_with_name_and_path.stub(:options){ { :name => 'global', :path => '/global' } }
    pro = Scide::Project.new global_with_name_and_path, 'fubar', :windows => []
    pro.options[:name].should_not == 'global'
    pro.options[:path].should_not == '/global'
  end

  it "should merge given options" do
    additional_options = { :name => 'fubar', :path => File.join(@path, 'fubar') }
    new_options = { :name => 'fubar2', :path => '/tmp2', :b => false, :c => 'foo' }
    pro = Scide::Project.new @global, 'fubar', :windows => [], :options => new_options
    pro.options.should == @options.merge(additional_options).merge(new_options)
  end

  describe 'Sample Configuration' do
    before :each do
      @contents = {
        :windows => [
          'window1 EDIT',
          { :name => 'window2', :command => 'SHOW', :contents => 'ssh example.com' },
          'window3 TAIL file.txt',
          { :string => 'window4 RUN ls -la' },
          'window5'
        ],
        :default_window => :window4
      }
      @project = Scide::Project.new @global, 'fubar', @contents
    end

    it "should create five windows" do
      @project.windows.length.should == 5
      @project.windows.each{ |w| w.should be_a(Scide::Window) }
    end

    it "should create the correct commands" do
      @project.windows[0].command.should be_a(Scide::Commands::Edit)
      @project.windows[1].command.should be_a(Scide::Commands::Show)
      @project.windows[2].command.should be_a(Scide::Commands::Tail)
      @project.windows[3].command.should be_a(Scide::Commands::Run)
      @project.windows[4].command.should be_nil
    end

    it "should find the correct default window" do
      @project.default_window.should == @project.windows[3]
    end

    it "should create the correct GNU Screen configuration" do
      @project.to_screen.should == SpecHelper.result(:project1)
    end

    describe 'Default Window' do
      before :each do
        @default_window_contents = @contents.dup
      end

      it "should find the default window with a fixnum" do
        @default_window_contents[:default_window] = 0
        project = Scide::Project.new(@global, 'fubar', @default_window_contents)
        project.default_window.should == project.windows[0]
      end

      it "should find the default window with a negative fixnum" do
        @default_window_contents[:default_window] = -4
        project = Scide::Project.new(@global, 'fubar', @default_window_contents)
        project.default_window.should == project.windows[1]
      end

      it "should find the default window with a string" do
        @default_window_contents[:default_window] = 'window3'
        project = Scide::Project.new(@global, 'fubar', @default_window_contents)
        project.default_window.should == project.windows[2]
      end

      it "should find the default window with a symbol" do
        @default_window_contents[:default_window] = :window5
        project = Scide::Project.new(@global, 'fubar', @default_window_contents)
        project.default_window.should == project.windows[4]
      end

      it "should raise an error if the default window is not a fixnum, string or symbol" do
        [ [], {}, 0.4 ].each do |invalid|
          @default_window_contents[:default_window] = invalid
          lambda{ Scide::Project.new @global, 'fubar', @default_window_contents }.should raise_error(ArgumentError)
        end
      end

      it "should raise an error if the default window is unknown" do
        [ 'unknown', :unknown, -10, -6, 5, 10 ].each do |invalid|
          @default_window_contents[:default_window] = invalid
          lambda{ Scide::Project.new @global, 'fubar', @default_window_contents }.should raise_error(ArgumentError)
        end
      end
    end
  end

  it "should raise an error if the contents are not a hash" do
    [ nil, '   ', [] ].each do |not_hash|
      lambda{ Scide::Project.new @global, 'fubar', not_hash }.should raise_error(ArgumentError)
    end
  end

  it "should raise an error if its windows are nil or not an array" do
    [ nil, '   ', {} ].each do |not_array|
      lambda{ Scide::Project.new @global, 'fubar', :windows => not_array }.should raise_error(ArgumentError)
    end
  end

  it "should raise an error if its options are not nil and not a hash" do
    [ '   ', [] ].each do |not_hash|
      lambda{ Scide::Project.new @global, 'fubar', :windows => [], :options => not_hash }.should raise_error(ArgumentError)
    end
  end
end
