require 'spec_helper'

RSpec.describe AppArchetype::Generators do
  describe '::TEMPLATE_MANIFEST' do
    let(:name) { 'project' }

    before do
      @manifest = Hashie::Mash.new(
        described_class::TEMPLATE_MANIFEST.call(name)
      )
    end

    it 'has expected name' do
      expect(@manifest.name).to eq name
    end

    it 'has expected version' do
      expect(@manifest.version).to eq '0.0.1'
    end

    it 'has app archetype metadata' do
      expect(@manifest.metadata.app_archetype).not_to be nil
    end

    it 'renders app version into archetype metadata' do
      expect(@manifest.metadata.app_archetype.version)
        .to eq AppArchetype::VERSION
    end

    it 'has default variables' do
      expect(@manifest.variables).to eq described_class::DEFAULT_VARS
    end
  end

  describe '::TEMPLATE_README' do
    let(:name) { 'project' }

    before do
      @readme = described_class::TEMPLATE_README.call(name)
    end

    it 'renders name into heading' do
      expect(@readme.include?("# #{name} Template")).to be true
    end

    it 'renders name into generation example' do
      expect(@readme.include?("mkdir my_#{name}")).to be true
      expect(@readme.include?("cd $HOME/Code/my_#{name}")).to be true
      expect(@readme.include?("archetype render #{name}")).to be true
    end
  end

  describe '.render_empty_template' do
    let(:manifest_file) { double }
    let(:manifest_path) { File.join(templates_path, 'manifest.json') }

    let(:readme_file) { double }
    let(:readme_path) { File.join(templates_path, 'README.md') }

    let(:name) { 'new_template' }
    let(:templates_path) { 'path/to/templates' }

    let(:manifest) { 'manifest' }
    let(:readme) { 'readme' }

    before do
      allow(File).to receive(:open)
        .with(manifest_path, 'w')
        .and_yield(manifest_file)
      allow(manifest_file).to receive(:write)

      allow(File).to receive(:open)
        .with(readme_path, 'w')
        .and_yield(readme_file)
      allow(readme_file).to receive(:write)

      allow(FileUtils).to receive(:mkdir_p)

      allow(described_class::TEMPLATE_MANIFEST)
        .to receive(:call).and_return(manifest)

      allow(described_class::TEMPLATE_README)
        .to receive(:call).and_return(readme)

      described_class.render_empty_template(
        name,
        templates_path
      )
    end

    it 'makes template dir' do
      expect(FileUtils)
        .to have_received(:mkdir_p)
        .with(File.join(templates_path, name))
    end

    it 'renders blank manifest' do
      expect(manifest_file)
        .to have_received(:write)
        .with("\"#{manifest}\"")
    end

    it 'renders readme' do
      expect(readme_file)
        .to have_received(:write)
        .with(readme)
    end
  end
end
