require 'spec_helper'

RSpec.describe AppArchetype::CLI do
  let(:options) { Hashie::Mash.new }

  subject { described_class.new }

  before do
    allow(subject).to receive(:options)
      .and_return(options)
  end

  describe '#version' do
    let(:command) { double }

    before do
      allow(command).to receive(:run)
      allow(AppArchetype::Commands::PrintVersion)
        .to receive(:new)
        .and_return(command)

      subject.version
    end

    it 'passes options to command' do
      expect(AppArchetype::Commands::PrintVersion)
        .to have_received(:new).with(options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#list' do
    let(:command) { double }
    let(:manager) { double }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(AppArchetype::Commands::ListTemplates)
        .to receive(:new)
        .and_return(command)

      subject.list
    end

    it 'passes manager and options to command' do
      expect(AppArchetype::Commands::ListTemplates)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#path' do
    let(:command) { double }
    let(:template_dir) { 'path/to/templates' }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:template_dir)
        .and_return(template_dir)

      allow(AppArchetype::Commands::PrintPath)
        .to receive(:new)
        .and_return(command)

      subject.path
    end

    it 'passes template path and options to command' do
      expect(AppArchetype::Commands::PrintPath)
        .to have_received(:new).with(template_dir, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#open' do
    let(:command) { double }
    let(:manager) { double }
    let(:editor) { 'vi' }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(subject).to receive(:editor).and_return(editor)
      allow(AppArchetype::Commands::OpenManifest)
        .to receive(:new)
        .and_return(command)

      subject.open
    end

    it 'passes manager, editor and options to command' do
      expect(AppArchetype::Commands::OpenManifest)
        .to have_received(:new).with(manager, editor, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#new' do
    let(:command) { double }
    let(:template_dir) { 'path/to/templates' }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:template_dir)
        .and_return(template_dir)

      allow(AppArchetype::Commands::NewTemplate)
        .to receive(:new)
        .and_return(command)

      subject.new
    end

    it 'passes template path and options to command' do
      expect(AppArchetype::Commands::NewTemplate)
        .to have_received(:new).with(template_dir, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#delete' do
    let(:command) { double }
    let(:manager) { double }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(AppArchetype::Commands::DeleteTemplate)
        .to receive(:new)
        .and_return(command)

      subject.delete
    end

    it 'passes manager and options to command' do
      expect(AppArchetype::Commands::DeleteTemplate)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#variables' do
    let(:command) { double }
    let(:manager) { double }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(AppArchetype::Commands::PrintTemplateVariables)
        .to receive(:new)
        .and_return(command)

      subject.variables
    end

    it 'passes manager and options to command' do
      expect(AppArchetype::Commands::PrintTemplateVariables)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#find' do
    let(:command) { double }
    let(:manager) { double }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(AppArchetype::Commands::FindTemplates)
        .to receive(:new)
        .and_return(command)

      subject.find
    end

    it 'passes manager and options to command' do
      expect(AppArchetype::Commands::FindTemplates)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#render' do
    let(:command) { double }
    let(:manager) { double }
    let(:out_path) { 'path/to/out' }
    let(:options) { Hashie::Mash.new(out: out_path) }

    before do
      allow(command).to receive(:run)
      allow(subject).to receive(:manager).and_return(manager)
      allow(AppArchetype::Commands::RenderTemplate)
        .to receive(:new)
        .and_return(command)

      subject.render
    end

    it 'passes manager, out path and options to command' do
      expect(AppArchetype::Commands::RenderTemplate)
        .to have_received(:new).with(manager, out_path, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#template_dir' do
    let(:template_dir) { 'path/to/template/dir' }
    let(:template_dir_exist) { false }

    before do
      allow(ENV)
        .to receive(:[])
        .with('ARCHETYPE_TEMPLATE_DIR')
        .and_return(template_dir)

      allow(File)
        .to receive(:exist?)
        .and_return(template_dir_exist)
    end

    context 'when environment variable not set' do
      let(:template_dir) { nil }

      it 'raises env var not set runtime error' do
        expect do
          subject.template_dir
        end.to raise_error(
          RuntimeError,
          'ARCHETYPE_TEMPLATE_DIR environment variable not set'
        )
      end
    end

    context 'when template directory does not exist' do
      it 'raises env var not exist runtime error' do
        expect do
          subject.template_dir
        end.to raise_error(
          RuntimeError,
          "ARCHETYPE_TEMPLATE_DIR #{template_dir} does not exist"
        )
      end
    end

    context 'when environment variable set and directory exists' do
      let(:template_dir_exist) { true }

      it 'returns template dir' do
        expect(subject.template_dir).to eq template_dir
      end
    end
  end

  describe '#editor' do
    let(:editor) { 'vi' }
    let(:editor_check_process_result) { double }

    before do
      allow(ENV)
        .to receive(:[])
        .with('ARCHETYPE_EDITOR')
        .and_return(editor)

      allow(subject).to receive(:puts)
    end

    context 'when editor is not set' do
      let(:editor) { nil }

      it 'raises archetype editor runtime error' do
        expect do
          subject.editor
        end.to raise_error(
          RuntimeError,
          'ARCHETYPE_EDITOR environment variable not set'
        )
      end
    end

    context 'when check exit status is non zero' do
      let(:editor) { 'not-valid-editor' }

      it 'warns user that the editor is not installed correctly' do
        subject.editor

        expect(subject)
          .to have_received(:puts)
          .with(
            "WARN: Configured editor #{editor} is not installed correctly "\
            'please check your configuration'
          )
      end
    end

    context 'when editor is set and check exit status is zero' do
      it 'returns editor' do
        expect(subject.editor).to eq editor
      end
    end
  end

  describe '#manager' do
    let(:template_dir) { 'path/to/template/dir' }
    let(:manager) { double(AppArchetype::TemplateManager) }

    before do
      allow(subject)
        .to receive(:template_dir)
        .and_return(template_dir)

      allow(AppArchetype::TemplateManager)
        .to receive(:new)
        .and_return(manager)

      allow(manager).to receive(:load)

      @manager = subject.manager
    end

    it 'creates a new template with template dir' do
      expect(AppArchetype::TemplateManager)
        .to have_received(:new)
        .with(template_dir)
    end

    it 'loads manager' do
      expect(manager).to have_received(:load)
    end

    it 'returns manager' do
      expect(@manager).to eq manager
    end
  end
end
