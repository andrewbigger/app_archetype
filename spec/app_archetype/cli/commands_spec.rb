require 'spec_helper'

RSpec.describe AppArchetype::CLI::Commands do
  describe '.render' do
    let(:dest_exist) { true }

    let(:dest) { 'path/to/output' }
    let(:manifest_name) { 'manifest name' }
    let(:args) { [manifest_name] }

    let(:manager) { double(AppArchetype::Manager) }

    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:variables) { double(AppArchetype::Template::Variables) }
    let(:template) { double(AppArchetype::Template::Source) }
    let(:plan) { double(AppArchetype::Template::Plan) }

    before do
      allow(File).to receive(:exist?).and_return(exist)
      allow(FileUtils).to receive(:mkdir_p)

      allow(AppArchetype::CLI).to receive(:manager).and_return(manager)

      allow(manager).to receive(:find).and_return(manifest)

      allow(manifest).to receive(:template).and_return(template)
      allow(manifest).to receive(:variables).and_return(variables)
      allow(template).to receive(:load)

      allow(AppArchetype::Template::Plan).to receive(:new).and_return(plan)

      allow(plan).to receive(:devise)
      allow(plan).to receive(:execute)

      described_class.render(dest, args)
    end

    context 'when destination does not exist' do
      let(:exist) { false }

      it 'creates a destination directory' do
        expect(FileUtils).to have_received(:mkdir_p).with(dest)
      end

      context 'when creation of destination fails' do
        before do
          allow(FileUtils).to receive(:mkdir_p).and_raise('something went awry')
        end

        it 'raises error' do
          expect { described_class.render(dest, args) }.to raise_error(
            RuntimeError,
            'cannot create destination directory'
          )
        end
      end
    end

    it 'finds manifest' do
      expect(manager).to have_received(:find).with(manifest_name)
    end

    it 'loads template' do
      expect(template).to have_received(:load)
    end

    it 'creates plan' do
      expect(AppArchetype::Template::Plan)
        .to have_received(:new)
        .with(template, variables, destination_path: dest, overwrite: false)
    end

    it 'devises plan' do
      expect(plan).to have_received(:devise)
    end

    it 'executes plan' do
      expect(plan).to have_received(:execute)
    end
  end

  describe '.list' do
    let(:manifest) { double }
    let(:manifests) { [manifest, manifest] }
    let(:manager) { double(AppArchetype::Manager) }

    before do
      allow(manager).to receive(:manifests)
        .and_return(manifests)

      allow(AppArchetype::CLI)
        .to receive(:manager)
        .and_return(manager)

      allow(AppArchetype::CLI::Presenters).to receive(:list)

      described_class.list(nil)
    end

    it 'lists manifests' do
      expect(AppArchetype::CLI::Presenters)
        .to have_received(:list)
        .with(manifests)
    end
  end

  describe '.find' do
    let(:search_term) { 'foo' }
    let(:manager) { double(AppArchetype::Manager) }
    let(:result) { double }

    before do
      allow(manager).to receive(:find)
        .with(search_term)
        .and_return(result)

      allow(AppArchetype::CLI)
        .to receive(:manager)
        .and_return(manager)

      allow(AppArchetype::CLI::Presenters).to receive(:show)
    end

    context 'when a search term is provided' do
      before { described_class.find(nil, [search_term]) }

      it 'does a search' do
        expect(manager)
          .to have_received(:find)
          .with(search_term)
      end

      it 'shows result' do
        expect(AppArchetype::CLI::Presenters)
          .to have_received(:show)
          .with(result)
      end
    end

    context 'when search term is not provided' do
      let(:search_term) { nil }

      it 'raises error' do
        expect { described_class.find(nil, []) }.to raise_error(
          RuntimeError,
          'no search term provided'
        )
      end
    end
  end

  describe '.template_dir' do
    let(:template_dir) { 'path/to/templates' }

    before do
      allow(AppArchetype::CLI)
        .to receive(:template_dir)
        .and_return(template_dir)

      allow(AppArchetype::CLI)
        .to receive(:print_message)

      described_class.template_dir(nil)
    end

    it 'prints template dir' do
      expect(AppArchetype::CLI)
        .to have_received(:print_message)
        .with(template_dir)
    end
  end
end
