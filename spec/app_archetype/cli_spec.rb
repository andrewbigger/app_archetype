require 'spec_helper'

RSpec.describe AppArchetype::CLI do
  let(:logger) { double(Logger) }
  let(:err_logger) { double(Logger) }
  let(:message) { 'All work and no play makes Jack a dull boy' }

  before do
    allow(described_class).to receive(:exit).and_return(double)
  end

  describe '.manager' do
    let(:manager) { double }
    let(:template_dir) { 'path/to/templates' }

    before do
      allow(described_class).to receive(:template_dir).and_return(template_dir)
      allow(AppArchetype::Manager).to receive(:new).and_return(manager)

      allow(manager).to receive(:load)

      @manager = described_class.manager
    end

    it 'creates a manager' do
      expect(AppArchetype::Manager).to have_received(:new).with(template_dir)
      expect(manager).to have_received(:load)
      expect(@manager).to eq manager
    end
  end

  describe '.template_dir' do
    let(:env_template_dir) { 'path/to/templates' }
    let(:exist) { true }

    before do
      allow(ENV).to receive(:[])
        .with('TEMPLATE_DIR')
        .and_return(env_template_dir)

      allow(File).to receive(:exist?).and_return(exist)
    end

    it 'returns template dir' do
      expect(described_class.template_dir).to eq env_template_dir
    end

    context 'when TEMPLATE_DIR environment variable not set' do
      let(:env_template_dir) { nil }

      it 'raises environment not set error' do
        expect { described_class.template_dir }.to raise_error(
          RuntimeError,
          'TEMPLATE_DIR environment not set'
        )
      end
    end

    context 'when templates do not exist' do
      let(:exist) { false }

      it 'raises environment not set error' do
        expect { described_class.template_dir }.to raise_error(
          RuntimeError,
          "TEMPLATE_DIR #{env_template_dir} does not exist"
        )
      end
    end
  end

  describe '.logger' do
    let(:out) { double(STDOUT) }
    before do
      allow(Logger).to receive(:new).and_return(logger)
      allow(logger).to receive(:formatter=)
      subject.logger(out)
    end

    it 'creates a new logger to STDOUT' do
      expect(Logger).to have_received(:new).with(out)
    end
  end

  describe '.print_message' do
    let(:logger) { double(Logger) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
      described_class.print_message(message)
    end

    it 'prints message to stdout' do
      expect(logger).to have_received(:info).with(message)
    end
  end

  describe '.print_warning' do
    let(:logger) { double(Logger) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:warn)
      described_class.print_warning(message)
    end

    it 'prints message to stdout' do
      expect(logger).to have_received(:warn).with(message)
    end
  end

  describe '.print_error' do
    let(:logger) { double(Logger) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:error)
      described_class.print_error(message)
    end

    it 'prints message to stderr' do
      expect(logger).to have_received(:error).with(message)
    end
  end

  describe '.print_message_and_exit' do
    let(:exit_code) { 2 }

    before do
      allow(described_class).to receive(:print_message)
      described_class.print_message_and_exit(message, exit_code)
    end

    it 'prints message' do
      expect(described_class).to have_received(:print_message).with(message)
    end

    it 'exits with set status' do
      expect(described_class).to have_received(:exit).with(exit_code)
    end
  end
end
