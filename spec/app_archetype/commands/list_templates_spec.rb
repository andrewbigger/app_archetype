require 'spec_helper'

RSpec.describe AppArchetype::Commands::ListTemplates do
  let(:options) { Hashie::Mash.new }

  let(:manifest_list_table) do
    <<~TABLE
      NAME          VERSION
      some-manifest 1.0.0  
    TABLE
  end

  let(:manager) { double(AppArchetype::TemplateManager) }
  let(:manifests) { [manifest] }

  let(:manifest) do
    double(
      AppArchetype::Template::Manifest,
      name: 'some-manifest',
      version: '1.0.0'
    )
  end

  subject { described_class.new(manager, options) }

  before do
    allow(manager)
      .to receive(:manifests)
      .and_return(manifests)

    allow(TTY::Table).to receive(:new).and_call_original
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    before { subject.run }

    it 'retrieves manifests from manager' do
      expect(manager).to have_received(:manifests)
    end

    it 'renders table' do
      expect(TTY::Table).to have_received(:new).with(
        header: AppArchetype::Commands::ListTemplates::RESULT_HEADER,
        rows: [['some-manifest', '1.0.0']]
      )
    end

    it 'prints table to STDOUT' do
      expect(subject)
        .to have_received(:puts)
        .with(manifest_list_table.strip)
    end
  end
end
