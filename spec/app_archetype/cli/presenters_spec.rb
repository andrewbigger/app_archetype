require 'spec_helper'

RSpec.describe AppArchetype::CLI::Presenters do
  describe '.show' do
    let(:template) { double(AppArchetype::Template) }
    let(:result_table) { double }
    let(:result_table_ascii) { 'ascii-table' }

    before do
      allow(AppArchetype::CLI).to receive(:print_message)

      allow(TTY::Table).to receive(:new).and_return(result_table)
      allow(result_table).to receive(:render).and_return(result_table_ascii)

      allow(template).to receive(:name).and_return('foo')
      allow(template).to receive(:version).and_return('1.0.0')
      allow(template).to receive(:path).and_return('path/to/manifest.json')

      described_class.show(template)
    end

    it 'prints table' do
      expect(AppArchetype::CLI)
        .to have_received(:print_message)
        .with(result_table_ascii)
    end

    context 'when not found' do
      let(:template) { nil }

      it 'prints not found' do
        expect(AppArchetype::CLI)
          .to have_received(:print_message)
          .with('not found')
      end
    end
  end

  describe '.list_templates' do
    let(:templates) { [template, template] }
    let(:template) { double(AppArchetype::Template) }
    let(:result_table) { double }
    let(:result_table_ascii) { 'ascii-table' }

    before do
      allow(AppArchetype::CLI).to receive(:print_message)

      allow(TTY::Table).to receive(:new).and_return(result_table)
      allow(result_table).to receive(:render).and_return(result_table_ascii)

      allow(template).to receive(:name).and_return('foo')
      allow(template).to receive(:version).and_return('1.0.0')
      allow(template).to receive(:path).and_return('path/to/manifest.json')

      described_class.list_templates(templates)
    end

    it 'prints table' do
      expect(AppArchetype::CLI)
        .to have_received(:print_message)
        .with(result_table_ascii)
    end
  end
end
