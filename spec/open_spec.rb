require 'helper'
require 'fileutils'

describe 'Scide.open' do
  include FakeFS::SpecHelpers

  let(:default_projects_dir){ File.expand_path('~/src') }
  let(:custom_projects_dir){ File.expand_path('~/Projects') }
  let(:env_projects_dir){ nil }
  let(:system_result){ true }
  let(:name){ nil }
  let(:options){ {} }
  let(:open_args){ (name ? [ name ] : []) + (options.empty? ? [] : [ options ]) }
  let(:expected_screenrc){ Regexp.escape '.screenrc' }

  before :each do

    # for temporary files
    FileUtils.mkdir_p '/tmp'

    # for which
    FileUtils.mkdir_p '/usr/bin'
    FileUtils.touch '/usr/bin/screen'
    FileUtils.chmod 0755, '/usr/bin/screen'

    # home folder
    FileUtils.mkdir_p File.expand_path('~')

    ENV['SCIDE_PROJECTS'] = env_projects_dir if env_projects_dir

    Kernel.stub system: system_result
  end

  it "should fail if screen is not in the path" do
    Which.stub which: nil
    expect_failure(/screen must be in the path/i){ Scide.open }
  end

  it "should fail if more than one project name is given" do
    expect_failure(/only one project name/i){ Scide.open 'a', 'b' }
  end

  it "should not open the home directory" do
    Dir.chdir File.expand_path('~')
    expect_failure(/home directory/i){ Scide.open }
  end

  shared_examples_for "a screen wrapper" do

    it "should execute the command" do
      expect_success /\A#{expected_chdir}screen -U -c #{expected_screenrc}\Z/
    end

    context "with a custom binary set by option" do

      let(:custom_bin){ '/bin/custom-screen' }
      let(:options){ super().merge bin: custom_bin }

      it "should execute the command with that binary" do
        expect_success /\A#{expected_chdir}#{Regexp.escape custom_bin} -U -c #{expected_screenrc}\Z/
      end
    end

    context "with a custom binary set by environment variable" do

      let(:custom_bin){ '/bin/custom-screen' }
      before(:each){ ENV['SCIDE_BIN'] = custom_bin }

      it "should execute the command with that binary" do
        expect_success /\A#{expected_chdir}#{Regexp.escape custom_bin} -U -c #{expected_screenrc}\Z/
      end
    end

    context "with custom screen options set by option" do

      let(:custom_screen){ '-r -x' }
      let(:options){ super().merge screen: custom_screen }

      it "should execute the command with those options" do
        expect_success /\A#{expected_chdir}screen -r -x -c #{expected_screenrc}\Z/
      end
    end

    context "with custom screen options set by environment variable" do

      let(:custom_screen){ '-r -x' }
      before(:each){ ENV['SCIDE_SCREEN'] = custom_screen }

      it "should execute the command with those options" do
        expect_success /\A#{expected_chdir}screen -r -x -c #{expected_screenrc}\Z/
      end
    end

    context "with the noop option" do
      
      let(:options){ super().merge noop: true }

      it "should print the command" do
        expect_success false, /\A#{expected_chdir}screen -U -c #{expected_screenrc}\Z/
      end
    end
  end

  context "for a project in the current directory" do

    let(:file){ '/projects/a/.screenrc' }
    let(:dir){ File.dirname file }
    before(:each){ Dir.chdir setup(dir, false) }

    it "should fail if there is no configuration file" do
      expect_failure /no such configuration/i
    end

    it "should fail if the configuration is not a file" do
      FileUtils.mkdir_p file
      expect_failure /not a file/i
    end

    context "with the auto option" do
      let(:expected_chdir){ nil }
      let(:expected_screenrc){ '.+' }
      let(:options){ super().merge auto: true }
      it_behaves_like "a screen wrapper"
    end

    context "if the project is valid" do
      let(:expected_chdir){ nil }
      before(:each){ FileUtils.touch file }
      it_behaves_like "a screen wrapper"
    end
  end

  shared_examples_for "a project in a configured directory" do

    it "should fail if the project directory doesn't exist" do
      expect_failure /no such directory/i
    end

    it "should fail if the project directory is not a directory" do
      FileUtils.mkdir_p File.dirname(dir)
      FileUtils.touch dir
      expect_failure /no such directory/i
    end

    it "should fail if there is no configuration file" do
      setup dir, false
      expect_failure /no such configuration/i
    end

    it "should fail if the configuration is not a file" do
      FileUtils.mkdir_p file
      expect_failure /not a file/i
    end

    context "with the auto option" do
      let(:expected_chdir){ Regexp.escape "cd #{Shellwords.escape dir} && " }
      let(:expected_screenrc){ '.+' }
      let(:options){ super().merge auto: true }
      before(:each){ setup dir, false }
      it_behaves_like "a screen wrapper"
    end

    context "if the project is valid" do
      let(:expected_chdir){ Regexp.escape "cd #{Shellwords.escape dir} && " }
      before(:each){ setup dir }
      it_behaves_like "a screen wrapper"
    end
  end

  context "for a project in the default project directory" do
    let(:name){ 'a' }
    let(:file){ File.join default_projects_dir, name, '.screenrc' }
    let(:dir){ File.dirname file }
    it_behaves_like "a project in a configured directory"
  end

  context "for a project in a custom project directory set by option" do
    let(:name){ 'a' }
    let(:file){ File.join custom_projects_dir, name, '.screenrc' }
    let(:dir){ File.dirname file }
    let(:options){ { projects: custom_projects_dir } }
    it_behaves_like "a project in a configured directory"
  end

  context "for a project in a custom project directory set by environment variable" do
    let(:name){ 'a' }
    let(:file){ File.join custom_projects_dir, name, '.screenrc' }
    let(:dir){ File.dirname file }
    let(:env_projects_dir){ custom_projects_dir }
    it_behaves_like "a project in a configured directory"
  end

  def open
    Scide.open *open_args
  end

  def setup dir, config = true
    dir = File.expand_path dir
    FileUtils.mkdir_p dir
    FileUtils.touch File.join(dir, '.screenrc') if config
    dir
  end

  def expect_success command, expected_result = nil, &block

    if command
      Kernel.should_receive(:system).with command
    else
      Kernel.should_not_receive(:system)
    end

    block = lambda{ open } unless block

    result = nil
    expect{ result = block.call }.to_not raise_error

    if !expected_result
      expect(result).to be_true if open_args.empty?
    elsif !command
      expect(result).to match(expected_result)
    end
  end

  def expect_failure *args, &block
    block = lambda{ open } unless block
    expect(&block).to raise_error(Scide::Error){ |e| args.each{ |msg| expect(e.message).to match(msg) } }
  end
end
