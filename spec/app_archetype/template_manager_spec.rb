require 'spec_helper'

RSpec.describe AppArchetype::TemplateManager do
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
    end

    context 'when manifest is valid' do
      before do
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

    context 'when a manifest is invalid' do
      before do
        allow(AppArchetype::Template::Manifest).to receive(:new_from_file)
          .and_raise('something went wrong parsing manifest')

        allow(subject).to receive(:puts)

        subject.load
      end

      it 'prints invalid template warning for each failed template' do
        expect(subject)
          .to have_received(:puts)
          .with('WARN: `path/to/dir/manifest.json` is invalid, skipping')
          .twice
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

  describe '#search_by_name' do
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

    let(:another_target_manifest) do
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
        another_target_manifest
      ]
    end

    before do
      subject.instance_variable_set(:@manifests, manifests)
      @result = subject.search_by_name(search_term)
    end

    it 'returns both matching manifests' do
      expect(@result).to eq(
        [
          target_manifest,
          another_target_manifest
        ]
      )
    end
  end

  describe '#find_by_name' do
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
    end

    it 'returns only matching manifest' do
      expect(subject.find_by_name(search_term)).to eq target_manifest
    end

    context 'when there are 2 manifests with the same name' do
      let(:manifests) do
        [
          manifest,
          manifest,
          target_manifest,
          target_manifest
        ]
      end

      it 'raises runtime error' do
        expect do
          subject.find_by_name(search_term)
        end.to raise_error(
          'more than one manifest matching the given name were found'
        )
      end

      context 'when ignoring duplicates' do
        it 'ignores error' do
          expect do
            subject.find_by_name(search_term, ignore_dupe: true)
          end.not_to raise_error
        end

        it 'returns first manifest' do
          expect(subject.find_by_name(search_term, ignore_dupe: true))
            .to eq target_manifest
        end
      end
    end
  end
end
