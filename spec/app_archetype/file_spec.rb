require 'spec_helper'

RSpec.describe AppArchetype::File do
  let(:source_file) { 'path/to/source' }
  let(:dest_file) { 'path/to/dest' }

  subject { described_class.new(source_file, dest_file) }

  describe '#source_directory?' do
    before do
      allow(::File).to receive(:directory?)
      subject.source_directory?
    end

    it 'delegates source file directory check to File' do
      expect(::File).to have_received(:directory?).with(source_file)
    end
  end

  describe '#source_template?' do
    let(:ext) { '.erb' }

    before do
      allow(::File).to receive(:extname).and_return(ext)
      @result = subject.source_template?
    end

    it 'delegates source file template check to File' do
      expect(::File).to have_received(:extname).with(source_file)
    end

    it 'returns true if file is erb' do
      expect(@result).to be true
    end

    context 'when not erb' do
      let(:ext) { 'doc' }

      it 'returns false' do
        expect(@result).to be false
      end
    end
  end

  describe '#source_file?' do
    before do
      allow(::File).to receive(:file?)
      subject.source_file?
    end

    it 'delegates source file check to File' do
      expect(::File).to have_received(:file?).with(source_file)
    end
  end

  describe '#exist?' do
    before do
      allow(::File).to receive(:exist?)
      subject.exist?
    end

    it 'delegates exist check to File' do
      expect(::File).to have_received(:exist?).with(dest_file)
    end
  end
end
