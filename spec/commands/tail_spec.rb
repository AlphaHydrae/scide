require 'helper'

describe Scide::Commands::Tail do

  it "should use given contents as argument -f of tail" do
    com = Scide::Commands::Tail.new 'fubar'
    com.text_with_options.should == 'tail -f fubar\012'
  end

  it "should use the :tail option as arguments to tail" do
    com = Scide::Commands::Tail.new 'fubar', :tail => '-n 1000'
    com.text_with_options.should == 'tail -n 1000 -f fubar\012'
  end
end
