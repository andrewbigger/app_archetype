require 'spec_helper'

RSpec.describe AppArchetype::Manifest do
  describe '.new_from_file' do
    let(:file_path) { 'path/to/manifest' }
    let(:exist) { true }
    let(:version) { '0.0.1' }
    let(:vars) { {} }
    let(:content) do
      "{ \"version\": \"#{version}\", \"variables\": #{vars.to_json} }"
    end

    before do
      allow(::File).to receive(:exist?).and_return(exist)
      allow(::File).to receive(:read).and_return(content)
      allow(JSON).to receive(:parse).and_return(JSON.parse(content))
    end

    context 'when file exists' do
      before do
        @parsed = described_class.new_from_file(file_path)
      end

      it 'reads file' do
        expect(::File).to have_received(:read).with(file_path)
      end

      it 'parses json' do
        expect(JSON).to have_received(:parse).with(content)
      end

      it 'returns manifest' do
        expect(@parsed).to be_a AppArchetype::Manifest
      end

      it 'has version' do
        expect(@parsed.version).to eq version
      end

      it 'has variables' do
        expect(@parsed.variables).to eq vars
      end
    end

    context 'when manifest is from a later version of app archetype' do
      let(:version) { '999.999.999' }

      it 'raises incompatibility error' do
        expect do
          described_class.new_from_file(file_path)
        end.to raise_error 'provided manifest is incompatible with this version'
      end
    end
  end

  describe '#name' do
    let(:path) { 'path/to/manifest.json' }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'variables' => {}
      }
    end

    before do
      @manifest = described_class.new(path, data)
    end

    it 'returns name' do
      expect(@manifest.name).to eq 'test_manifest'
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

    before do
      @manifest = described_class.new(path, data)
    end

    it 'returns version' do
      expect(@manifest.version).to eq '0.1.0'
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
    let(:template) { double(AppArchetype::Template) }

    before do
      allow(::File).to receive(:exist?).and_return(exist)

      @manifest = described_class.new(path, data)
    end

    it 'loads template adjacent to manifest' do
      expect(@manifest.template.source_path).to eq('path/to/template')
    end

    context 'when template files do not exist' do
      let(:exist) { false }

      it 'raises cannot find template error' do
        expect { @manifest.template }.to raise_error(
          RuntimeError,
          'cannot find template for manifest test_manifest'
        )
      end
    end
  end

  describe '#valid?' do
    let(:path) { 'path/to/manifest.json' }

    let(:data) do
      {
        'name' => 'test_manifest',
        'version' => '0.1.0',
        'variables' => {}
      }
    end

    before do
      @manifest = described_class.new(path, data)
    end

    it 'returns true' do
      expect(@manifest.valid?).to be true
    end

    context 'when missing version' do
      let(:data) { { 'variables' => {} } }

      it 'returns false' do
        expect(@manifest.valid?).to be false
      end
    end
  end
end
