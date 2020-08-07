require 'spec_helper'

RSpec.describe AppArchetype::CLI do
  subject { described_class.new }

  describe '.manager' do
    let(:manager) { double }
    let(:template_dir) { 'path/to/templates' }

    before do
      allow(described_class).to receive(:template_dir).and_return(template_dir)
      allow(AppArchetype::TemplateManager).to receive(:new).and_return(manager)

      allow(manager).to receive(:load)

      @manager = described_class.manager
    end

    it 'creates a manager' do
      expect(AppArchetype::TemplateManager)
        .to have_received(:new)
        .with(template_dir)

      expect(manager).to have_received(:load)
      expect(@manager).to eq manager
    end
  end

  describe '.template_dir' do
    let(:env_template_dir) { 'path/to/templates' }
    let(:exist) { true }

    before do
      allow(ENV).to receive(:[])
        .with('ARCHETYPE_TEMPLATE_DIR')
        .and_return(env_template_dir)

      allow(File).to receive(:exist?).and_return(exist)
    end

    it 'returns template dir' do
      expect(described_class.template_dir).to eq env_template_dir
    end

    context 'when ARCHETYPE_TEMPLATE_DIR environment variable not set' do
      let(:env_template_dir) { nil }

      it 'raises environment not set error' do
        expect { described_class.template_dir }.to raise_error(
          RuntimeError,
          'ARCHETYPE_TEMPLATE_DIR environment variable not set'
        )
      end
    end

    context 'when templates do not exist' do
      let(:exist) { false }

      it 'raises environment not set error' do
        expect { described_class.template_dir }.to raise_error(
          RuntimeError,
          "ARCHETYPE_TEMPLATE_DIR #{env_template_dir} does not exist"
        )
      end
    end
  end

  describe '.editor' do
    let(:env_editor) { 'ivm' }
    let(:exit_status) { 0 }

    before do
      allow(ENV).to receive(:[])
        .with('ARCHETYPE_EDITOR')
        .and_return(env_editor)

      allow(described_class).to receive(:`)
      allow($?).to receive(:exitstatus).and_return(exit_status)
    end

    it 'returns editor' do
      expect(described_class.editor).to eq env_editor
    end

    context 'when ARCHETYPE_EDITOR environment variable not set' do
      let(:env_editor) { nil }

      it 'raises environment not set error' do
        expect { described_class.editor }.to raise_error(
          RuntimeError,
          'ARCHETYPE_EDITOR environment variable not set'
        )
      end
    end

    context 'when editor check does not pass' do
      let(:exit_status) { 1 }

      before do
        allow(AppArchetype::CLI).to receive(:print_warning)
        described_class.editor
      end

      it 'logs a warning' do
        expect(AppArchetype::CLI)
          .to have_received(:print_warning)
          .with(
            "WARN: Configured editor #{env_editor} is not installed correctly "\
            'please check your configuration'
          )
      end
    end
  end

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#version' do
    before do
      allow(subject).to receive(:print_message)
      subject.version
    end

    it 'prints current version number' do
      expect(subject).to have_received(:print_message)
        .with(AppArchetype::VERSION)
    end
  end
end
