require 'spec_helper'

RSpec.describe AppArchetype::Commands::OpenManifest do
  let(:manager) { AppArchetype::TemplateManager }
  let(:editor) { 'vi' }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, editor, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:template_name) { 'template-name' }
    let(:manifest_path) { 'path/to/manifest' }
    let(:editor) { 'vi' }
    let(:manifest) { double(AppArchetype::Template::Manifest) }

    before do
      allow(prompt)
        .to receive(:select)
        .and_return(template_name)

      allow(manager)
        .to receive(:find_by_name)
        .and_return(manifest)

      allow(manager)
        .to receive(:manifest_names)
        .and_return([template_name])

      allow(manifest)
        .to receive(:path)
        .and_return(manifest_path)

      allow(Process).to receive(:spawn)
      allow(Process).to receive(:waitpid)

      allow(subject).to receive(:puts)

      subject.run
    end

    context 'when name is provided in options' do
      describe 'when the template is found' do
        it 'finds template by name' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(template_name)
        end

        it 'runs editor process' do
          expect(Process)
            .to have_received(:spawn)
            .with("#{editor} #{manifest_path}")
        end

        it 'waits for process' do
          expect(Process)
            .to have_received(:waitpid)
        end
      end

      describe 'when the template is not found' do
        let(:manifest) { nil }

        it 'attempts to find template by name' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(template_name)
        end

        it 'prints manifest not found message' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No manifests with name `#{template_name}` found.")
        end

        it 'does not start editor process' do
          expect(Process)
            .not_to have_received(:spawn)
        end
      end
    end

    context 'when name is not provided in options' do
      it 'prompts user to choose template' do
        expect(prompt)
          .to have_received(:select)
          .with('Please choose manifest', [template_name])
      end

      it 'finds template by name' do
        expect(manager)
          .to have_received(:find_by_name)
          .with(template_name)
      end

      it 'starts editor process' do
        expect(Process)
          .to have_received(:spawn)
          .with("#{editor} #{manifest_path}")
      end

      it 'waits for process' do
        expect(Process)
          .to have_received(:waitpid)
      end
    end
  end
end
