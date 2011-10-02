require 'helper'

module Scide
  module Commands
    class FuBar < Scide::Commands::Show
    end
  end
end

describe Scide::Command do

  it "should be abstract" do
    com = Scide::Command.new 'fubar'
    lambda{ com.to_screen }.should raise_error(StandardError)
  end

  it "should use given contents as text" do
    com = Scide::Command.new 'fubar'
    com.text_with_options.should == 'fubar'
  end

  it "should take options" do
    com = Scide::Command.new 'fubar %{foo} %{bar}', :foo => 1, :bar => 2
    com.text_with_options.should == 'fubar 1 2'
  end

  describe 'Class' do
    before :each do
      @options = { :a => 1, :b => true }
      @window = double('window')
      @window.stub(:options){ @options }
    end
    
    it "should resolve command with a string" do
      com = Scide::Command.resolve @window, 'SHOW fubar'
      com.should be_a_kind_of(Scide::Commands::Show)
    end

    it "should use second part of string as contents when resolving a command with a string" do
      com = Scide::Command.resolve @window, 'SHOW fubar'
      com.text_with_options.should == 'fubar'
    end

    it "should resolve command with a hash" do
      com = Scide::Command.resolve @window, :command => 'SHOW', :contents => 'fubar'
      com.should be_a_kind_of(Scide::Commands::Show)
    end

    it "should give duplicated window options to the resolved string command" do
      @window.should_receive :options
      com = Scide::Command.resolve @window, 'SHOW fubar'
      com.options.should == @options
      com.options.should_not equal(@options)
    end

    it "should give duplicated window options to the resolved hash command" do
      @window.should_receive :options
      com = Scide::Command.resolve @window, :command => 'SHOW', :contents => 'fubar'
      com.options.should == @options
      com.options.should_not equal(@options)
    end

    it "should resolve camel-case command class names with a string" do
      com = Scide::Command.resolve @window, 'FU_BAR'
      com.should be_a_kind_of(Scide::Commands::FuBar)
    end

    it "should resolve camel-case command class names with a hash" do
      com = Scide::Command.resolve @window, :command => 'FU_BAR'
      com.should be_a_kind_of(Scide::Commands::FuBar)
    end

    it "should raise an error when type of contents is unknown" do
      lambda{ Scide::Command.resolve(@window, []) }.should raise_error(ArgumentError)
    end

    it "should raise an error when trying to resolve a blank string" do
      lambda{ Scide::Command.resolve(@window, '   ') }.should raise_error(ArgumentError)
    end

    it "should raise an error when trying to resolve an unknown command" do
      lambda{ Scide::Command.resolve(@window, 'SHW fubar') }.should raise_error(ArgumentError)
      lambda{ Scide::Command.resolve(@window, :command => 'SHW', :contents => 'fubar') }.should raise_error(ArgumentError)
    end
  end
end
