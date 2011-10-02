require 'helper'

describe Scide::Commands::Show do

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
