require 'spec_helper'

RSpec.describe AppArchetype::Template::Plan do
  let(:template) { AppArchetype::Template::Source.new('path/to/template') }
  let(:destination) { 'path/to/destination' }
  let(:variables) do
    OpenStruct.new(
      foo: 'bar'
    )
  end

  subject do
    described_class.new(
      template,
      variables,
      destination_path: destination
    )
  end

  describe '#devise' do
    let(:dest_exist) { true }

    before do
      allow(subject).to receive(:destination_exist?).and_return(dest_exist)
      allow(template).to receive(:files).and_return(['path/to/file'])
    end

    it 'creates file objects' do
      subject.devise
      expect(subject.files).to all be_a(AppArchetype::Template::OutputFile)
    end

    context 'destination path does not exist' do
      let(:dest_exist) { false }

      it 'raises error' do
        expect do
          subject.devise
        end.to raise_error('destination path does not exist')
      end
    end
  end

  describe '#execute' do
    let(:renderer) { double(AppArchetype::Renderer) }

    before do
      allow(renderer).to receive(:render)
      allow(AppArchetype::Renderer)
        .to receive(:new)
        .and_return(renderer)

      subject.execute
    end

    it 'creates a renderer' do
      expect(AppArchetype::Renderer)
        .to have_received(:new).with(subject, false)
    end

    it 'renders plan' do
      expect(renderer).to have_received(:render)
    end
  end

  describe '#destination_exist?' do
    let(:dirname) { 'some-directory' }
    let(:exist) { true }

    before do
      allow(File).to receive(:exist?).and_return(exist)
      allow(File).to receive(:dirname).and_return(dirname)
    end

    it 'returns true' do
      expect(subject.destination_exist?).to be true
    end

    context 'when destination does not exist' do
      let(:exist) { false }

      it 'returns false' do
        expect(subject.destination_exist?).to be false
      end
    end
  end

  describe '#render_dest_file_path' do
    it 'creates a destination file path from source path' do
      expect(
        subject.render_dest_file_path('path/to/template/file')
      ).to eq 'path/to/destination/file'
    end
  end

  describe '#render_path' do
    it 'renders path with variables' do
      expect(subject.render_path('{{foo}}')).to eq 'bar'
    end
  end
end

RSpec.describe AppArchetype::Template::OutputFile do
  let(:source_file) { 'path/to/source' }
  let(:dest_file) { 'path/to/dest' }

  subject { described_class.new(source_file, dest_file) }

  describe '#source_directory?' do
    before do
      allow(File).to receive(:directory?)
      subject.source_directory?
    end

    it 'delegates source file directory check to File' do
      expect(File).to have_received(:directory?).with(source_file)
    end
  end

  describe '#source_erb?' do
    let(:ext) { '.erb' }

    before do
      allow(File).to receive(:extname).and_return(ext)
      @result = subject.source_erb?
    end

    it 'delegates source file template check to File' do
      expect(File).to have_received(:extname).with(source_file)
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

  describe '#source_hbs?' do
    let(:ext) { '.hbs' }

    before do
      allow(File).to receive(:extname).and_return(ext)
      @result = subject.source_hbs?
    end

    it 'delegates source file template check to File' do
      expect(File).to have_received(:extname).with(source_file)
    end

    it 'returns true if file is hbs' do
      expect(@result).to be true
    end

    context 'when not hbs' do
      let(:ext) { 'doc' }

      it 'returns false' do
        expect(@result).to be false
      end
    end
  end

  describe '#source_file?' do
    before do
      allow(File).to receive(:file?)
      subject.source_file?
    end

    it 'delegates source file check to File' do
      expect(File).to have_received(:file?).with(source_file)
    end
  end

  describe '#exist?' do
    before do
      allow(File).to receive(:exist?)
      subject.exist?
    end

    it 'delegates exist check to File' do
      expect(File).to have_received(:exist?).with(dest_file)
    end
  end
end
