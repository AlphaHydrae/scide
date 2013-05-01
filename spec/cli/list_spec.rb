require 'helper'

describe 'scide list' do

  let(:argv){ [ 'list' ] }
  let(:expected_options){ {} }

  before :each do
    Scide.stub :list
    Scide.stub(:open).and_raise(StandardError.new('open should not be called'))
  end

  shared_examples_for "list" do

    it "should output nothing if there are no projects" do
      Scide.stub list: []
      expect_success "\n"
    end

    it "should output the list of projects" do
      Scide.stub list: [ '.', 'a', 'b', 'c' ]
      expect_success ".\na\nb\nc\n"
    end

    context "if it fails" do
     
      before :each do
        Scide.stub(:list).and_raise(Scide::Error.new('fubar'))
      end

      it "should output the error to stderr" do
        expect_failure "fubar#{Scide::Program::BACKTRACE_NOTICE}"
      end

      context "with the trace option" do
        
        let(:argv){ super().unshift '--trace' }

        it "should raise the error" do
          expect_failure "fubar", true
        end
      end
    end
  end

  it_behaves_like "list"

  [ '-p', '--projects' ].each do |opt|
    context "with the #{opt} option" do
      let(:projects_dir){ '~/Projects' }
      let(:expected_options){ { projects: projects_dir } }
      let(:argv){ super() + [ opt, projects_dir ] }
      it_behaves_like "list"
    end
  end

  def expect_success output
    Scide.should_receive(:list).with expected_options
    program = Scide::Program.new argv
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr
    expect{ program.run! }.to_not raise_error
    $stdout, $stderr = STDOUT, STDERR
    expect(stdout.string).to eq(output)
    expect(stderr.string).to be_empty
  end

  def expect_failure message, expect_raise = false, code = 1, &block
    program = Scide::Program.new argv
    if expect_raise
      expect{ program.run! }.to raise_error(Scide::Error){ |e| expect(e.message).to eq(message) }
    else
      stderr = StringIO.new
      $stderr = stderr
      expect{ program.run! }.to raise_error(SystemExit){ |e| expect(e.status).to eq(code) }
      $stderr = STDERR
      expect(Paint.unpaint(stderr.string.strip)).to eq(message)
    end
  end
end
