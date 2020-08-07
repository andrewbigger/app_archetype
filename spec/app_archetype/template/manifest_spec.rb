require 'spec_helper'

RSpec.describe AppArchetype::Template::Manifest do
  describe '.new_from_file' do
    let(:file_path) { 'path/to/manifest' }
    let(:exist) { true }
    let(:manifest_name) { 'manifest name' }

    let(:app_archetype_meta) do
      {
        'app_archetype' => {
          'version' => AppArchetype::VERSION
        }
      }
    end

    let(:version) { '0.0.1' }
    let(:vars) do
      {
        'foo' => {
          'description' => 'a foo',
          'default' => 'bar'
        },
        'bar' => {
          'description' => 'a bar',
          'default' => 'foo'
        }
      }
    end
    let(:content) do
      {
        'name' => manifest_name,
        'version' => version,
        'metadata' => app_archetype_meta,
        'variables' => vars
      }.to_json
    end

    before do
      allow(File).to receive(:exist?).and_return(exist)
      allow(File).to receive(:read).and_return(content)
      allow(Jsonnet).to receive(:evaluate).and_call_original
    end

    context 'when file exists' do
      before do
        @parsed = described_class.new_from_file(file_path)
      end

      it 'reads file' do
        expect(File).to have_received(:read).with(file_path)
      end

      it 'parses json' do
        expect(Jsonnet).to have_received(:evaluate).with(content)
      end

      it 'returns manifest' do
        expect(@parsed).to be_a AppArchetype::Template::Manifest
      end

      it 'has version' do
        expect(@parsed.version).to eq version
      end

      it 'has variables' do
        expect(@parsed.variables).to be_a AppArchetype::Template::VariableManager
      end
    end

    context 'when manifest is from a later version of app archetype' do
      let(:app_archetype_meta) do
        {
          'app_archetype' => {
            'version' => '999.999.999'
          }
        }
      end

      it 'raises incompatibility error' do
        expect do
          described_class.new_from_file(file_path)
        end.to raise_error 'provided manifest is invalid or incompatible with '\
        'this version of app archetype'
      end
    end

    context 'when manifest is from an earlier incompatible version of app archetype' do
      let(:app_archetype_meta) do
        {
          'app_archetype' => {
            'version' => '0.9.9'
          }
        }
      end

      it 'raises incompatibility error' do
        expect do
          described_class.new_from_file(file_path)
        end.to raise_error 'provided manifest is invalid or incompatible with '\
        'this version of app archetype'
      end
    end

    context 'when app_archetype metadata is missing' do
      let(:app_archetype_meta) { {} }
      it 'raises incompatibility error' do
        expect do
          described_class.new_from_file(file_path)
        end.to raise_error 'provided manifest is invalid or incompatible with '\
        'this version of app archetype'
      end
    end
  end

  subject { described_class.new(path, data) }

  describe '#name' do
    let(:path) { 'path/to/manifest.json' }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'variables' => {}
      }
    end

    it 'returns name' do
      expect(subject.name).to eq 'test_manifest'
    end
  end

  describe '#version' do
    let(:path) { 'path/to/manifest.json' }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'variables' => {}
      }
    end

    it 'returns version' do
      expect(subject.version).to eq '0.1.0'
    end
  end

  describe '#metadata' do
    let(:path) { 'path/to/manifest.json' }
    let(:meta) { { 'foo' => 'bar' } }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'metadata' => meta,
        'variables' => {}
      }
    end

    it 'returns metadata' do
      expect(subject.metadata).to eq meta
    end
  end

  describe '#template' do
    let(:path) { 'path/to/manifest.json' }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'variables' => {}
      }
    end

    let(:exist) { true }
    let(:template) { double(AppArchetype::Template::Source) }

    before do
      allow(File).to receive(:exist?).and_return(exist)
    end

    it 'loads template adjacent to manifest' do
      expect(subject.template.path).to eq('path/to/template')
    end

    context 'when template files do not exist' do
      let(:exist) { false }

      it 'raises cannot find template error' do
        expect { subject.template }.to raise_error(
          RuntimeError,
          'cannot find template for manifest test_manifest'
        )
      end
    end
  end

  describe 'validate' do
    let(:path) { 'path/to/manifest.json' }
    let(:data) { {} }
    let(:result) { [] }

    before do
      allow(JSON::Validator).to receive(:fully_validate).and_return(result)
      subject.validate
    end

    it 'runs json schema validation with manifest schema' do
      expect(JSON::Validator).to have_received(:fully_validate)
        .with(
          AppArchetype::Template::Manifest::SCHEMA,
          data.to_json,
          strict: true
        )
    end
  end

  describe '#valid?' do
    let(:path) { 'path/to/manifest.json' }
    let(:data) { {} }
    let(:validation_results) { [] }

    before do
      allow(subject).to receive(:validate).and_return(validation_results)
    end

    context 'when manifest is valid' do
      it 'returns true' do
        expect(subject.valid?).to be true
      end
    end

    context 'when manifest is invalid' do
      let(:validation_results) { ['there was a validation error'] }
      it 'returns true' do
        expect(subject.valid?).to be false
      end
    end
  end
end
