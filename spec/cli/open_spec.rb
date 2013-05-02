require 'helper'

describe 'scide open' do

  let(:argv){ [] }
  let(:expected_args){ [] }
  let(:expected_options){ {} }
  let(:expected_output){ expected_options[:noop] ? fake_command : '' }
  let(:fake_command){ 'foo' }

  before :each do
    Scide.stub :open
    Scide.stub(:list).and_raise(StandardError.new('list should not be called'))
    Scide.stub(:setup).and_raise(StandardError.new('setup should not be called'))
  end

  shared_examples_for "open" do

    before :each do
      Scide.stub open: fake_command
    end

    it "should open the current directory" do
      expect_success
    end

    context "with a project name" do
      let(:argv){ super().push 'a' }
      let(:expected_args){ [ 'a' ] }

      it "should open the project" do
        expect_success
      end
    end

    context "if it fails" do

      before :each do
        Scide.stub(:open).and_raise(Scide::Error.new('fubar'))
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

  it_behaves_like "open"

  [ '-p', '--projects' ].each do |opt|
    context "with the #{opt} option" do
      let(:projects_dir){ '~/Projects' }
      let(:expected_options){ { projects: projects_dir } }
      let(:argv){ [ opt, projects_dir ] }
      it_behaves_like "open"
    end
  end

  [ '-a', '--auto' ].each do |opt|
    context "with the #{opt} option" do
      let(:expected_options){ { auto: true } }
      let(:argv){ [ opt ] }
      it_behaves_like "open"
    end
  end

  [ '-n', '--noop' ].each do |opt|
    context "with the #{opt} option" do
      let(:expected_options){ { noop: true } }
      let(:argv){ [ opt ] }
      it_behaves_like "open"
    end
  end

  [ '-b', '--bin' ].each do |opt|
    context "with the #{opt} option" do
      let(:expected_options){ { bin: '/bin/custom-screen' } }
      let(:argv){ [ opt, '/bin/custom-screen' ] }
      it_behaves_like "open"
    end
  end

  [ '-s', '--screen' ].each do |opt|
    context "with the #{opt} option" do
      let(:expected_options){ { screen: '-a' } }
      let(:argv){ [ opt, "-a" ] }
      it_behaves_like "open"
    end
  end

  context "with all options" do
    let(:projects_dir){ '~/Projects' }
    let(:expected_options){ { projects: projects_dir, auto: true, bin: '/bin/custom-screen', screen: '-r -x', noop: true } }
    let(:argv){ [ '--projects', projects_dir, '--auto', '--bin', '/bin/custom-screen', '--screen', '-r -x', '--noop' ] }
    it_behaves_like "open"
  end

  def expect_success *args
    args = args.empty? ? expected_args + (expected_options.empty? ? [] : [ expected_options ]) : args
    Scide.should_receive(:open).with *args
    program = Scide::Program.new argv
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr
    expect{ program.run! }.to_not raise_error
    $stdout, $stderr = STDOUT, STDERR
    expect(Paint.unpaint(stdout.string.chomp "\n")).to eq(expected_output)
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
      expect(Paint.unpaint(stderr.string.strip)).to eq(message)
      $stderr = STDERR
    end
  end
end
