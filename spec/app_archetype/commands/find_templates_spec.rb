require 'spec_helper'

RSpec.describe AppArchetype::Commands::FindTemplates do
  let(:manager) { double(AppArchetype::TemplateManager) }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:prompt_response) { nil }
    let(:found_manifests) { [] }

    let(:manifest_name) { 'some-template' }
    let(:manifest_version) { '1.0.0' }

    let(:manifest) do
      double(
        AppArchetype::Template::Manifest,
        name: manifest_name,
        version: manifest_version
      )
    end

    before do
      allow(prompt)
        .to receive(:ask)
        .and_return(prompt_response)

      allow(manager)
        .to receive(:search_by_name)
        .and_return(found_manifests)

      allow(subject).to receive(:puts)
    end

    context 'when name is provided in options' do
      let(:options) do
        Hashie::Mash.new(
          name: manifest_name
        )
      end

      describe 'and the template is not found' do
        before { subject.run }

        it 'uses manager to search for template by name' do
          expect(manager)
            .to have_received(:search_by_name)
            .with(manifest_name)
        end

        it 'prints no manifests found message' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No manifests with name `#{manifest_name}` found.")
        end
      end

      describe 'and the template is found' do
        let(:found_manifests) { [manifest] }

        before { subject.run }

        it 'uses manager to search for template by name' do
          expect(manager)
            .to have_received(:search_by_name)
            .with(manifest_name)
        end

        it 'prints manifest list table' do
          expected_table = <<~TABLE
            NAME          VERSION
            #{manifest_name} #{manifest_version}
          TABLE

          expect(subject)
            .to have_received(:puts)
            .with(expected_table.strip)
        end
      end
    end

    context 'when the name is not provided in options' do
      before do
        allow(prompt).to receive(:ask).and_return(manifest_name)
        subject.run
      end

      it 'prompts user for a template name' do
        expect(prompt)
          .to have_received(:ask)
          .with('Please enter a template name')
      end

      it 'uses manager to search for template by name' do
        expect(manager)
          .to have_received(:search_by_name)
          .with(manifest_name)
      end

      describe 'when there are results' do
        let(:found_manifests) { [manifest] }

        it 'prints manifest list table' do
          expected_table = <<~TABLE
            NAME          VERSION
            #{manifest_name} #{manifest_version}
          TABLE

          expect(subject)
            .to have_received(:puts)
            .with(expected_table.strip)
        end
      end

      describe 'when there are no results' do
        it 'prints no manifests found messsage' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No manifests with name `#{manifest_name}` found.")
        end
      end
    end
  end
end
