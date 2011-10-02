require 'helper'

describe Scide::Commands::Edit do

  it "should use the preferred editor" do
    com = Scide::Commands::Edit.new nil
    com.text_with_options.should == '$EDITOR\012'
  end

  it "should use given contents as arguments to the editor" do
    com = Scide::Commands::Edit.new 'fubar'
    com.text_with_options.should == '$EDITOR fubar\012'
  end

  it "should use the :edit option as arguments to the editor" do
    com = Scide::Commands::Edit.new 'fubar', :edit => '-c MyCommand'
    com.text_with_options.should == '$EDITOR -c MyCommand fubar\012'
  end
end
