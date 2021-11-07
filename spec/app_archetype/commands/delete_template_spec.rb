require 'spec_helper'

RSpec.describe AppArchetype::Commands::DeleteTemplate do
  let(:manager) { double(AppArchetype::TemplateManager) }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:ok_to_proceed) { true }
    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:manifest_parent_path) { 'path/to/template' }
    let(:manifest_name) { 'some-manifest' }

    before do
      allow(manager).to receive(:find_by_name).and_return(manifest)
      allow(manager).to receive(:manifest_names).and_return([manifest_name])

      allow(prompt).to receive(:select).and_return(manifest_name)
      allow(prompt).to receive(:yes?).and_return(ok_to_proceed)

      allow(manifest)
        .to receive(:parent_path)
        .and_return(manifest_parent_path)

      allow(FileUtils).to receive(:rm_rf)
      allow(subject).to receive(:puts)
      subject.run
    end

    context 'when name is provided in options' do
      let(:options) do
        Hashie::Mash.new(
          name: manifest_name
        )
      end

      describe 'and the manifest is found' do
        it 'finds the manifest' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'asks whether to proceed' do
          expect(prompt)
            .to have_received(:yes?)
            .with("Are you sure you want to delete #{manifest_name}?")
        end

        describe 'when we should delete the template' do
          it 'removes template' do
            expect(FileUtils).to have_received(:rm_rf)
              .with(manifest_parent_path)
          end

          it 'prints success message' do
            expect(subject).to have_received(:puts)
              .with("✔ Template `#{manifest_name}` has been removed")
          end
        end

        describe 'when we should not delete the template' do
          let(:ok_to_proceed) { false }

          it 'does not remove the template' do
            expect(FileUtils).not_to have_received(:rm_rf)
          end
        end
      end

      describe 'and the manifest is not found' do
        let(:manifest) { nil }

        it 'attempts to find the manifest' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'prints manifest not found message' do
          expect(subject).to have_received(:puts)
            .with("✖ No template with name `#{manifest_name}` found.")
        end
      end
    end

    context 'when name is not provided in options' do
      before do
        allow(prompt)
          .to receive(:select)
          .and_return(manifest_name)
      end

      it 'prompts the user to choose the manifest for deletion' do
        expect(prompt)
          .to have_received(:select)
          .with('Please choose template for deletion', [manifest_name])
      end

      it 'asks whether to proceed' do
        expect(prompt).to have_received(:yes?)
          .with("Are you sure you want to delete #{manifest_name}?")
      end

      describe 'when we should delete the template' do
        it 'removes template' do
          expect(FileUtils).to have_received(:rm_rf)
            .with(manifest_parent_path)
        end

        it 'prints success message' do
          expect(subject).to have_received(:puts)
            .with("✔ Template `#{manifest_name}` has been removed")
        end
      end

      describe 'when we should not delete the template' do
        let(:ok_to_proceed) { false }

        it 'does not remove the template' do
          expect(FileUtils).not_to have_received(:rm_rf)
        end
      end
    end
  end
end
