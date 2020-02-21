require 'spec_helper'

RSpec.describe AppArchetype::Template::Source do
  let(:path) { 'path/to/source' }
  subject { described_class.new(path) }

  describe '#load' do
    let(:glob_files) { %w[file1 file2] }
    let(:exist) { true }

    before do
      allow(Dir).to receive(:glob).and_return(glob_files)
      allow(subject).to receive(:exist?).and_return(exist)
    end

    context 'when source exists' do
      before do
        subject.load
      end

      it 'loads expected file paths into source_files' do
        expect(subject.files).to eq glob_files
      end
    end

    context 'when source does not exist' do
      let(:exist) { false }

      it 'raises template source does not exist error' do
        expect do
          subject.load
        end.to raise_error('template source does not exist')
      end
    end
  end

  describe '#exist?' do
    let(:path) { 'path/to/source' }
    let(:exist) { true }

    before { allow(::File).to receive(:exist?).and_return(exist) }

    it 'checks if file exists' do
      expect(::File).to receive(:exist?).with(path)
      subject.exist?
    end

    it 'returns true' do
      expect(subject.exist?).to be true
    end

    context 'when file does not exist' do
      let(:exist) { false }

      it 'returns false' do
        expect(subject.exist?).to be false
      end
    end
  end
end
