require 'spec_helper'

RSpec.describe AppArchetype::CLI::Commands do
  let(:template_path) { 'path/to/template' }
  let(:dest_path) { 'path/to/destination' }
  let(:manifest_path) { 'path/to/manifest' }
  let(:overwrite) { false }
  let(:vars) { ['k1:v1'] }

  let(:parsed_manifest_vars) { Hashie::Mash.new(foo: 'bar', biz: 'buz') }
  let(:parsed_cli_vars) { Hashie::Mash.new(biz: 'baz') }

  let(:manifest_data) do
    {
      'version' => '0.0.1',
      'variables' => parsed_manifest_vars
    }
  end
  let(:manifest) do
    AppArchetype::Manifest.new(manifest_data)
  end

  let(:template) { double(AppArchetype::Template) }
  let(:plan) { double(AppArchetype::Plan) }
  let(:renderer) { double(AppArchetype::Renderer) }

  before do
    allow(AppArchetype::Manifest).to receive(:new_from_file)
      .and_return(manifest)

    allow(AppArchetype::Template).to receive(:new).and_return(template)
    allow(AppArchetype::Plan).to receive(:new).and_return(plan)
    allow(AppArchetype::Renderer).to receive(:new).and_return(renderer)

    allow(AppArchetype::Variables)
      .to receive(:new_from_file)
      .and_return(parsed_manifest_vars)

    allow(AppArchetype::Variables)
      .to receive(:new_from_args)
      .and_return(parsed_cli_vars)

    allow(template).to receive(:load)
    allow(plan).to receive(:devise)
    allow(renderer).to receive(:render)
  end

  context 'when the manifest is valid' do
    before do
      described_class.render(
        template_path,
        dest_path,
        manifest_path,
        overwrite,
        vars
      )
    end

    it 'loads the template' do
      expect(AppArchetype::Template).to have_received(:new).with(template_path)
      expect(template).to have_received(:load)
    end

    it 'overrides manifest variables with cli variables' do
      merged_variables = { 'biz' => 'baz', 'foo' => 'bar' }

      expect(AppArchetype::Plan)
        .to have_received(:new)
        .with(template, dest_path, merged_variables)
    end

    it 'devises plan' do
      expect(plan).to have_received(:devise)
    end

    it 'renders template' do
      expect(renderer).to have_received(:render)
    end
  end

  context 'when manifest is invalid' do
    let(:manifest_data) { {} }
    it 'raises invalid manifest error' do
      expect do
        described_class.render(
          template_path,
          dest_path,
          manifest_path,
          overwrite,
          vars
        )
      end.to raise_error 'invalid manifest'
    end
  end
end

RSpec.describe AppArchetype::CLI do
  let(:logger) { double(Logger) }
  let(:message) { 'All work and no play makes Jack a dull boy' }

  before do
    allow(described_class).to receive(:exit).and_return(double)
  end

  describe '.logger' do
    before do
      allow(Logger).to receive(:new).and_return(logger)
      allow(logger).to receive(:formatter=)
      @logger = subject.logger
    end

    it 'creates a new logger to STDOUT' do
      expect(Logger).to have_received(:new).with(STDOUT)
    end
  end

  describe '.print_message' do
    let(:logger) { double(Logger) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
      described_class.print_message(message)
    end

    it 'prints message to stdout' do
      expect(logger).to have_received(:info).with(message)
    end
  end

  describe '.print_message_and_exit' do
    let(:exit_code) { 2 }

    before do
      allow(described_class).to receive(:print_message)
      described_class.print_message_and_exit(message, exit_code)
    end

    it 'prints message' do
      expect(described_class).to have_received(:print_message).with(message)
    end

    it 'exits with set status' do
      expect(described_class).to have_received(:exit).with(exit_code)
    end
  end
end
