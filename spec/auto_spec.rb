require 'helper'
require 'fileutils'

describe Scide do
  include FakeFS::SpecHelpers

  before :each do
    FileUtils.mkdir_p '/tmp'
  end

  context ".auto_config_file" do

    before(:each){ Scide.stub auto_config: 'foo' }

    it "should create a temporary configuration file" do
      Scide.auto_config_file do |auto_file|
        expect(auto_file).to be_a_kind_of(Tempfile)
      end
    end

    it "should create a file containing the results of ::auto_config" do
      Scide.auto_config_file do |auto_file|
        expect(File.read(auto_file)).to eq('foo')
      end
    end
  end

  context ".auto_config" do

    let(:expected_config){ %|screen -t editor 0\nstuff "\\${PROJECT_EDITOR-\\$EDITOR}\\012"\nscreen -t shell 1\nselect editor| }
    subject{ Scide.auto_config }

    it{ should eq(expected_config) }

    context "with a .screenrc file in the home directory" do
      let(:expected_config){ %|source $HOME/.screenrc\n\n#{super()}| }
      before(:each){ setup '~' }
      it{ should eq(expected_config) }
    end
  end

  context ".auto?" do

    let(:options){ {} }
    let(:env_auto){ nil }
    subject{ Scide.auto? options }
    it{ should be_false }

    before :each do
      ENV['SCIDE_AUTO'] = env_auto if env_auto
    end
    
    context "with the auto option" do
      let(:options){ { auto: true } }
      it{ should be_true }
    end

    [ '1', 'y', 'yes', 't', 'true' ].each do |valid|
      context "with $SCIDE_AUTO set to #{valid}" do
        let(:env_auto){ valid }
        it{ should be_true }
      end
    end
  end

  def setup dir, config = true
    dir = File.expand_path dir
    FileUtils.mkdir_p dir
    FileUtils.touch File.join(dir, '.screenrc') if config
    dir
  end
end
