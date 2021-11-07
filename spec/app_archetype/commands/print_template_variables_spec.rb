require 'spec_helper'

RSpec.describe AppArchetype::Commands::PrintTemplateVariables do
  let(:manager) { double(AppArchetype::TemplateManager) }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:prompt_response) { nil }
    let(:found_manifest) { nil }

    let(:manifest_name) { 'some-template' }
    let(:manifest_version) { '1.0.0' }

    let(:manifest) do
      double(
        AppArchetype::Template::Manifest,
        name: manifest_name,
        version: manifest_version,
        variables: variables
      )
    end

    let(:variable_name) { 'script_name' }
    let(:variable_description) { 'Name of script' }
    let(:variable_default) { 'bashy-bash' }

    let(:variables) do
      double(AppArchetype::Template::VariableManager)
    end

    let(:variable) do
      AppArchetype::Template::Variable.new(
        variable_name,
        {
          name: variable_name,
          description: variable_description,
          default: variable_default
        }
      )
    end

    before do
      allow(prompt)
        .to receive(:select)
        .and_return(prompt_response)

      allow(manager)
        .to receive(:manifest_names)
        .and_return([manifest_name])

      allow(manager)
        .to receive(:find_by_name)
        .and_return(found_manifest)

      allow(variables)
        .to receive(:all)
        .and_return([variable])

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
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'prints no manifests found message' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No manifests with name `#{manifest_name}` found.")
        end
      end

      describe 'and the template is found' do
        let(:found_manifest) { manifest }

        before { subject.run }

        it 'uses manager to search for template by name' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'prints manifest list table' do
          expected_table = <<~TABLE
            NAME        DESCRIPTION    DEFAULT   
            #{variable_name} #{variable_description} #{variable_default}
          TABLE

          expect(subject)
            .to have_received(:puts)
            .with(expected_table.strip)
        end
      end
    end

    context 'when the name is not provided in options' do
      before do
        allow(prompt).to receive(:select).and_return(manifest_name)
        subject.run
      end

      it 'prompts user for a template name' do
        expect(prompt)
          .to have_received(:select)
          .with('Please choose manifest', [manifest_name])
      end

      it 'uses manager to search for template by name' do
        expect(manager)
          .to have_received(:find_by_name)
          .with(manifest_name)
      end

      describe 'when there is a result' do
        let(:found_manifest) { manifest }

        it 'prints manifest list table' do
          expected_table = <<~TABLE
            NAME        DESCRIPTION    DEFAULT   
            #{variable_name} #{variable_description} #{variable_default}
          TABLE

          expect(subject)
            .to have_received(:puts)
            .with(expected_table.strip)
        end
      end

      describe 'when there is no result' do
        it 'prints no manifests found messsage' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No manifests with name `#{manifest_name}` found.")
        end
      end
    end
  end
end
