require 'helper'

describe Scide::Commands::Run do

  it "should use given contents and a carriage return as text" do
    com = Scide::Commands::Run.new 'fubar'
    com.text_with_options.should == 'fubar\012'
  end
end
