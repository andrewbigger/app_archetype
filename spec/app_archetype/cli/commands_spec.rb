require 'spec_helper'

RSpec.describe AppArchetype::CLI::Commands do
  describe '.render' do
    let(:dest_exist) { true }

    let(:dest) { 'path/to/output' }
    let(:manifest_name) { 'manifest name' }
    let(:args) { [manifest_name] }

    let(:manager) { double(AppArchetype::Manager) }

    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:manifest_valid) { true }

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
      allow(manifest).to receive(:valid?).and_return(manifest_valid)

      allow(template).to receive(:load)

      allow(AppArchetype::Template::Plan).to receive(:new).and_return(plan)

      allow(plan).to receive(:devise)
      allow(plan).to receive(:execute)
    end

    describe 'rendering a project' do
      before { described_class.render(dest, args) }

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

    context 'when template name is not provided' do
      let(:manifest_name) { nil }

      it 'raises template name not provided runtime error' do
        expect { described_class.render(dest, args) }.to raise_error(
          RuntimeError,
          'template name not provided'
        )
      end
    end

    context 'when destination does not exist' do
      let(:exist) { false }

      before { described_class.render(dest, ['my-manifest']) }

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

  describe '.new' do
    let(:template_dir) { 'path/to/templates' }

    let(:project_name) { 'some/proj' }
    let(:args) { [project_name] }
    let(:exist) { true }

    before do
      allow(AppArchetype::CLI)
        .to receive(:template_dir)
        .and_return(template_dir)

      allow(File).to receive(:exist?).and_return(exist)
      allow(FileUtils).to receive(:mkdir_p)
      allow(AppArchetype::Generators).to receive(:render_empty_template)
    end

    it 'generates an empty template' do
      described_class.new(nil, args)

      expect(AppArchetype::Generators)
        .to have_received(:render_empty_template)
        .with('proj', 'path/to/templates/some/proj')
    end

    context 'when template name is not provided' do
      let(:project_name) { nil }

      it 'returns template rel not provided runtime error' do
        expect { described_class.new(nil, args) }.to raise_error(
          RuntimeError,
          'template rel not provided'
        )
      end
    end

    context 'when the destination directory does not exist' do
      let(:exist) { false }

      it 'makes destination directory' do
        described_class.new(nil, args)
        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with("#{template_dir}/#{project_name}")
      end

      context 'when it cannot create destination directory' do
        before do
          allow(FileUtils)
            .to receive(:mkdir_p)
            .and_raise('something went wrong')
        end

        it 'raises cannot create directory runtime error' do
          expect { described_class.new(nil, args) }.to raise_error(
            RuntimeError,
            'cannot create destination directory'
          )
        end
      end
    end
  end

  describe '.open' do
    let(:editor) { 'ivm' }
    let(:manifest_name) { 'mah manifest' }
    let(:args) { [manifest_name] }

    let(:manager) { double(AppArchetype::Manager) }
    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:manifest_path) { 'path/to/manifest.json' }

    before do
      allow(AppArchetype::CLI).to receive(:editor).and_return(editor)
      allow(AppArchetype::CLI).to receive(:manager).and_return(manager)
      allow(manager).to receive(:find).and_return(manifest)
      allow(manifest).to receive(:path).and_return(manifest_path)
      allow(Process).to receive(:spawn)
      allow(Process).to receive(:waitpid)
    end

    it 'opens manifest with specified editor' do
      described_class.open(nil, args)

      expect(Process)
        .to have_received(:spawn)
        .with("#{editor} #{manifest_path}")
    end

    context 'when manfiest name is not specified' do
      let(:manifest_name) { nil }

      it 'raises template name not specified runtime error' do
        expect { described_class.open(nil, args) }.to raise_error(
          RuntimeError,
          'template name not provided'
        )
      end
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
