require 'spec_helper'

RSpec.describe AppArchetype do
  let(:collection_dir) { 'path/to/collection' }
  let(:template_name) { 'template' }
  let(:destination_path) { 'path/to/destination' }

  describe '.render_template' do
    let(:manager) { double(AppArchetype::TemplateManager) }
    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:template) { double(AppArchetype::Template) }
    let(:command) { double(AppArchetype::Commands::RenderTemplate) }
    let(:options) do
      Hashie::Mash.new(
        name: template_name,
        overwrite: false
      )
    end

    before do
      allow(AppArchetype::TemplateManager)
        .to receive(:new)
        .and_return(manager)

      allow(manager).to receive(:load)
      allow(manager).to receive(:find_by_name).and_return(manifest)
      allow(manifest).to receive(:template).and_return(template)
      allow(template).to receive(:load)

      allow(AppArchetype::Commands::RenderTemplate)
        .to receive(:new)
        .and_return(command)

      allow(command).to receive(:run)

      @manifest = described_class.render_template(
        collection_dir: collection_dir,
        template_name: template_name,
        destination_path: destination_path
      )
    end

    it 'loads manager' do
      expect(manager).to have_received(:load)
    end

    it 'finds template by name' do
      expect(manager).to have_received(:find_by_name)
    end

    it 'loads template' do
      expect(template).to have_received(:load)
    end

    it 'runs render command' do
      expect(AppArchetype::Commands::RenderTemplate)
        .to have_received(:new)
        .with(manager, destination_path, options)
    end

    it 'returns manifest' do
      expect(@manifest).to eq manifest
    end
  end
end
