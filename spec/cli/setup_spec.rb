require 'helper'

describe 'scide setup' do

  let(:argv){ [ 'setup' ] }
  let(:expected_args){ [] }
  let(:expected_options){ {} }
  let(:expected_output){ '' }

  before :each do
    Scide.stub :setup
    Scide.stub(:list).and_raise(StandardError.new('list should not be called'))
    Scide.stub(:open).and_raise(StandardError.new('open should not be called'))
  end

  shared_examples_for "setup" do

    let(:config_file){ '~/some/.screenrc' }
    let(:expected_output){ config_file }

    it "should output the path to the created file" do
      Scide.stub setup: '~/some/.screenrc'
      expect_success
    end

    context "if it fails" do
     
      before :each do
        Scide.stub(:setup).and_raise(Scide::Error.new('fubar'))
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

  it_behaves_like "setup"

  [ '-p', '--projects' ].each do |opt|
    context "with the #{opt} option" do
      let(:projects_dir){ '~/Projects' }
      let(:expected_options){ { projects: projects_dir } }
      let(:argv){ super() + [ opt, projects_dir ] }
      it_behaves_like "setup"
    end
  end

  def expect_success output = nil
    args = expected_args + (expected_options.empty? ? [] : [ expected_options ])
    Scide.should_receive(:setup).with *args
    program = Scide::Program.new argv
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr
    expect{ program.run! }.to_not raise_error
    $stdout, $stderr = STDOUT, STDERR
    expect(Paint.unpaint(stdout.string.chomp "\n")).to eq(output || expected_output)
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
