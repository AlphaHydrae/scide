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
  let(:args){ (name ? [ name ] : []) + (options.empty? ? [] : [ options ]) }

  before :each do

    FileUtils.mkdir_p '/usr/bin'
    FileUtils.touch '/usr/bin/screen'
    FileUtils.chmod 0755, '/usr/bin/screen'
    FileUtils.mkdir_p File.expand_path('~')

    if env_projects_dir
      ENV['SCIDE_PROJECTS'] = env_projects_dir
    else
      ENV.delete 'SCIDE_PROJECTS'
    end

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
      expect_success "#{expected_chdir}screen -U -c .screenrc"
    end

    context "with a custom binary" do

      let(:custom_bin){ '/bin/custom-screen' }
      let(:options){ super().merge bin: custom_bin }

      it "should execute the command with that binary" do
        expect_success "#{expected_chdir}#{custom_bin} -U -c .screenrc"
      end
    end

    context "with custom options" do

      let(:custom_screen){ '-a' }
      let(:options){ super().merge screen: custom_screen }

      it "should execute the command with those options" do
        expect_success "#{expected_chdir}screen -a -c .screenrc"
      end
    end

    context "with the noop option" do
      
      let(:options){ super().merge noop: true }

      it "should print the command" do
        expect_success false, "#{expected_chdir}screen -U -c .screenrc"
      end
    end
  end

  context "for a project in the current directory" do

    let(:file){ '/projects/a/.screenrc' }
    let(:dir){ File.dirname file }

    before :each do
      FileUtils.mkdir_p dir
      Dir.chdir dir
    end

    it "should fail if there is no configuration file" do
      expect_failure /no such configuration/i
    end

    it "should fail if the configuration is not a file" do
      FileUtils.mkdir_p file
      expect_failure /not a file/i
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
      expect_failure /not a directory/i
    end

    it "should fail if there is no configuration file" do
      FileUtils.mkdir_p dir
      expect_failure /no such configuration/i
    end

    it "should fail if the configuration is not a file" do
      FileUtils.mkdir_p file
      expect_failure /not a file/i
    end

    context "if the project is valid" do

      let(:expected_chdir){ "cd #{Shellwords.escape dir} && " }

      before :each do
        FileUtils.mkdir_p dir
        FileUtils.touch file
      end

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
    Scide.open *args
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
      expect(result).to be_true if args.empty?
    elsif !command
      expect(result).to eq(expected_result)
    end
  end

  def expect_failure *args, &block
    block = lambda{ open } unless block
    expect(&block).to raise_error(Scide::Error){ |e| args.each{ |msg| expect(e.message).to match(msg) } }
  end
end
