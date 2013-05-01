require 'helper'

describe 'Scide.list' do
  include FakeFS::SpecHelpers

  let(:default_projects_dir){ File.expand_path('~/src') }
  let(:custom_projects_dir){ File.expand_path('~/Projects') }
  let(:env_projects_dir){ nil }
  let(:options){ {} }

  before :each do

    FileUtils.mkdir_p File.expand_path('~')

    if env_projects_dir
      ENV['SCIDE_PROJECTS'] = env_projects_dir
    else
      ENV.delete 'SCIDE_PROJECTS'
    end
  end

  shared_examples_for "listings" do

    it "should fail if the projects directory is a file" do
      FileUtils.mkdir_p File.dirname(projects_dir)
      FileUtils.touch projects_dir
      expect_failure /no such directory/i
    end

    context "if the projects directory doesn't exist" do

      it "should fail if current directory is the home directory" do
        Dir.chdir setup('~', false)
        expect_failure /no such directory/i
      end

      it "should fail if the current directory isn't a project" do
        Dir.chdir setup('~/some', false)
        expect_failure /no such directory/i
      end

      it "should return the current directory if it's a project" do
        Dir.chdir setup('~/some')
        expect(list).to eq([ '.' ])
      end
    end

    context "if the projects directory exists" do

      before :each do
        FileUtils.mkdir_p projects_dir
      end

      it "should return an empty list if there are no projects" do
        expect(list).to be_empty
      end

      it "should return the current directory if it's a project" do
        Dir.chdir setup('~/some')
        expect(list).to eq([ '.' ])
      end

      it "should return the projects with a .screenrc file in the projects directory" do
        setup File.join(projects_dir, 'a')
        setup File.join(projects_dir, 'b'), false
        setup File.join(projects_dir, 'c')
        setup File.join(projects_dir, 'd')
        setup File.join(projects_dir, 'e'), false
        expect(list).to eq([ 'a', 'c', 'd' ])
      end

      it "should return the projects in the projects directory and the current directory" do
        Dir.chdir setup('~/some')
        setup File.join(projects_dir, 'a')
        setup File.join(projects_dir, 'b')
        setup File.join(projects_dir, 'c'), false
        expect(list).to eq([ '.', 'a', 'b' ])
      end

      it "should not return the projects directory" do
        setup projects_dir
        expect(list).to be_empty
      end
    end
  end

  context "with the default projects directory" do
    let(:projects_dir){ default_projects_dir }
    it_behaves_like "listings"
  end

  context "with a custom projects directory set by option" do
    let(:projects_dir){ custom_projects_dir }
    let(:options){ { projects: custom_projects_dir } }
    it_behaves_like "listings"
  end

  context "with a custom projects directory set by environment variable" do
    let(:projects_dir){ custom_projects_dir }
    let(:env_projects_dir){ custom_projects_dir }
    it_behaves_like "listings"
  end

  def setup dir, config = true
    dir = File.expand_path dir
    FileUtils.mkdir_p dir
    FileUtils.touch File.join(dir, '.screenrc') if config
    dir
  end

  def expect_failure *args, &block
    block = lambda{ list } unless block
  end

  def list
    Scide.list options
  end
end
