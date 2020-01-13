require 'spec_helper'

RSpec.describe AppArchetype::Variables do
  describe '.new_from_args' do
    let(:args) { ['k1:v1', 'k2:v2'] }

    context 'given valid arguments' do
      before do
        @parsed = described_class.new_from_args(args)
      end

      it 'returns variables' do
        expect(@parsed).to be_a AppArchetype::Variables
      end

      it 'has expected variables' do
        expect(@parsed.k1).to eq 'v1'
        expect(@parsed.k2).to eq 'v2'
      end
    end

    context 'given malformed arguments' do
      let(:args) { ['k1:', 'k2:v2:v2'] }

      it 'raises malformed variable argument error' do
        expect do
          described_class.new_from_args(args)
        end.to raise_error 'malformed variable argument: k1:'
      end
    end
  end

  describe '.new_from_file' do
    let(:file_path) { 'path/to/file' }
    let(:exist) { true }
    let(:content) { '{ "k1": "v1", "k2": "v2" }' }

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

      it 'returns hashie mash' do
        expect(@parsed).to be_a Hashie::Mash
      end

      it 'has expected variables' do
        expect(@parsed.k1).to eq 'v1'
        expect(@parsed.k2).to eq 'v2'
      end
    end
  end

  describe '#dot' do
    before do
      @vars = described_class.new({})
    end

    it 'returns empty string' do
      expect(@vars.dot).to eq ''
    end
  end
end
