require 'spec_helper'

RSpec.describe AppArchetype::Plan do
  let(:template) { AppArchetype::Template.new('path/to/template') }
  let(:destination) { 'path/to/destination' }
  let(:variables) do
    Hashie::Mash.new(
      foo: 'bar'
    )
  end

  subject { described_class.new(template, destination, variables) }

  describe '#devise' do
    let(:dest_exist) { true }

    before do
      allow(subject).to receive(:destination_exist?).and_return(dest_exist)
      template.instance_variable_set(:@source_files, ['path/to/file'])
    end

    it 'creates file objects' do
      subject.devise
      expect(subject.files).to all be_a(AppArchetype::File)
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

  describe '#destination_exist?' do
    let(:dirname) { 'some-directory' }
    let(:exist) { true }

    before do
      allow(::File).to receive(:exist?).and_return(exist)
      allow(::File).to receive(:dirname).and_return(dirname)
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
