require 'helper'

describe 'Scide.setup' do
  include FakeFS::SpecHelpers

  let(:default_projects_dir){ File.expand_path('~/src') }
  let(:custom_projects_dir){ File.expand_path('~/Projects') }
  let(:env_projects_dir){ nil }
  let(:expected_contents){ 'foo' }
  let(:name){ nil }
  let(:options){ {} }
  let(:setup_args){ (name ? [ name ] : []) + (options.empty? ? [] : [ options ]) }

  before :each do
    FileUtils.mkdir_p File.expand_path('~')
    ENV['SCIDE_PROJECTS'] = env_projects_dir if env_projects_dir
    Scide.stub auto_config: expected_contents
  end

  shared_examples_for "setting up" do

    it "should fail if more than one project name is given" do
      expect_failure(/only one project name/i){ Scide.setup 'a', 'b' }
    end

    it "should not set up the home directory" do
      Dir.chdir File.expand_path('~')
      expect_failure /home directory/i
    end

    context "the current directory" do

      let(:dir){ '~/some' }

      it "should fail if a .screenrc file already exists" do
        Dir.chdir setup(dir)
        expect_failure /already exists/i
      end

      it "should setup the default configuration" do
        Dir.chdir setup(dir, false)
        expect_success File.join(dir, '.screenrc')
      end
    end

    context "a project directory" do

      let(:name){ 'a' }
      let(:project_dir){ File.join projects_dir, name }

      before :each do
        FileUtils.mkdir_p projects_dir
      end

      it "should fail if a .screenrc file already exists" do
        Dir.chdir setup(project_dir)
        expect_failure /already exists/i
      end

      it "should setup the default configuration" do
        Dir.chdir setup(project_dir, false)
        expect_success File.join(project_dir, '.screenrc')
      end
    end
  end

  context "with the default projects directory" do
    let(:projects_dir){ default_projects_dir }
    it_behaves_like "setting up"
  end

  context "with a custom projects directory set by option" do
    let(:projects_dir){ custom_projects_dir }
    let(:options){ { projects: custom_projects_dir } }
    it_behaves_like "setting up"
  end

  context "with a custom projects directory set by environment variable" do
    let(:projects_dir){ custom_projects_dir }
    let(:env_projects_dir){ custom_projects_dir }
    it_behaves_like "setting up"
  end

  def setup dir, config = true
    dir = File.expand_path dir
    FileUtils.mkdir_p dir
    FileUtils.touch File.join(dir, '.screenrc') if config
    dir
  end

  def expect_success path, noop = false
    result = nil
    expect{ result = do_setup *setup_args }.to_not raise_error
    expect(result).to eq(File.expand_path(path))
    expect(File.read(result)).to eq(expected_contents) unless noop
  end

  def expect_failure *args, &block
    block = lambda{ do_setup *setup_args } unless block
    expect(&block).to raise_error(Scide::Error){ |e| args.each{ |msg| expect(e.message).to match(msg) } }
  end

  def do_setup *args
    Scide.setup *args
  end
end
