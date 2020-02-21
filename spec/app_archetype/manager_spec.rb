require 'spec_helper'

RSpec.describe AppArchetype::Manager do
  let(:template_dir) { 'path/to/templates' }

  subject do
    described_class.new(template_dir)
  end

  describe '#load' do
    let(:manifest_file) { 'path/to/dir/manifest.json' }

    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:files) do
      [
        manifest_file,
        manifest_file
      ]
    end

    before do
      allow(Dir).to receive(:glob).and_return(files)
      allow(AppArchetype::Template::Manifest).to receive(:new_from_file)
        .and_return(manifest)

      subject.load
    end

    it 'loads manifests' do
      expect(subject.manifests.count).to be 2

      subject.manifests.each do |manifest|
        expect(manifest).to eq manifest
      end
    end
  end

  describe '#filter' do
    let(:query) do
      ->(manifest) { manifest == target_manifest }
    end

    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:target_manifest) { double(AppArchetype::Template::Manifest) }

    let(:manifests) do
      [
        manifest,
        manifest,
        target_manifest
      ]
    end

    before do
      subject.instance_variable_set(:@manifests, manifests)
      @result = subject.filter(query)
    end

    it 'finds target manifest in set' do
      expect(@result.count).to be 1
      expect(@result.first).to eq target_manifest
    end

    context 'when no query is defined' do
      before do
        @results = subject.filter
      end

      it 'returns everything' do
        expect(@results.count).to eq 3
      end
    end
  end

  describe '#find' do
    let(:search_term) { 'target' }
    let(:lang) { '.rb' }

    let(:manifest) do
      AppArchetype::Template::Manifest.new(
        'path/to/manifest.json',
        'name' => 'manifest'
      )
    end

    let(:target_manifest) do
      AppArchetype::Template::Manifest.new(
        'path/to/manifest.json',
        'name' => 'target'
      )
    end

    let(:almost_target_manifest) do
      AppArchetype::Template::Manifest.new(
        'path/to/manifest.json',
        'name' => 'target and more'
      )
    end

    let(:manifests) do
      [
        manifest,
        manifest,
        target_manifest,
        almost_target_manifest
      ]
    end

    before do
      subject.instance_variable_set(:@manifests, manifests)
      @result = subject.find(search_term)
    end

    it 'returns first found' do
      expect(@result).to eq target_manifest
    end
  end
end
