require 'helper'

describe Scide::Commands::Show do

  it "should use given contents as text" do
    com = Scide::Commands::Show.new 'fubar'
    com.text_with_options.should == 'fubar'
  end

  it "should take options" do
    com = Scide::Commands::Show.new 'fubar %{foo} %{bar}', :foo => 1, :bar => 2
    com.text_with_options.should == 'fubar 1 2'
  end

  it "should produce a GNU Screen stuff command" do
    com = Scide::Commands::Show.new 'fubar'
    com.to_screen.should == 'stuff "fubar"'
  end

  it "should use #text_with_options as argument to stuff" do
    com = Scide::Commands::Show.new 'fubar'
    text_with_options = com.text_with_options
    com.to_screen.should == %|stuff "#{text_with_options}"|
  end
end
