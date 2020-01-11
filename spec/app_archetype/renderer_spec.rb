require 'spec_helper'

RSpec.describe AppArchetype::Renderer do
  let(:template) { AppArchetype::Template.new('path/to/template') }
  let(:destination) { 'path/to/destination' }
  let(:variables) do
    Hashie::Mash.new(
      foo: 'bar'
    )
  end
  let(:plan) do
    AppArchetype::Plan.new(template, destination, variables)
  end
  let(:overwrite) { false }

  subject { described_class.new(plan, variables, overwrite) }

  describe '#render' do
    let(:file) do
      AppArchetype::File.new('path/to/source/file', 'path/to/destination/file')
    end

    let(:template) do
      AppArchetype::File.new('path/to/tmplte.erb', 'path/to/destination/tmplte')
    end

    let(:directory) do
      AppArchetype::File.new('path/to/source/dir', 'path/to/destination/dir')
    end

    before do
      allow(subject).to receive(:write_dir)
      allow(subject).to receive(:render_file)
      allow(subject).to receive(:copy_file)

      allow(file).to receive(:source_file?).and_return(true)
      allow(template).to receive(:source_template?).and_return(true)
      allow(directory).to receive(:source_directory?).and_return(true)

      plan.instance_variable_set(:@files, [file, template, directory])
      subject.render
    end

    it 'creates destination directory' do
      expect(subject).to have_received(:write_dir).with(destination)
    end

    it 'creates directory' do
      expect(subject).to have_received(:write_dir).with(directory)
    end

    it 'renders template' do
      expect(subject).to have_received(:render_file).with(template)
    end

    it 'copies file' do
      expect(subject).to have_received(:copy_file).with(file)
    end
  end

  describe '#write_dir' do
    let(:source_path) { 'path/to/template/dir' }
    let(:dest_path) { 'path/to/destination/dir' }
    let(:dir) { AppArchetype::File.new(source_path, dest_path) }
    let(:exists) { false }

    before do
      allow(FileUtils).to receive(:mkdir_p)
    end

    it 'creates directory' do
      subject.write_dir(dir)
      expect(FileUtils).to have_received(:mkdir_p).with(dest_path)
    end
  end

  describe '#render_file' do
    let(:source_path) { 'path/to/template/file' }
    let(:dest_path) { 'path/to/destination/file' }
    let(:file) { AppArchetype::File.new(source_path, dest_path) }

    let(:input) do
      <<~INPUT
        this is the content of the <%= foo %> file
      INPUT
    end

    let(:expected_output) do
      <<~OUTPUT
        this is the content of the bar file
      OUTPUT
    end

    let(:write_double) { double }

    before do
      allow(File).to receive(:read).and_return(input)
      allow(File).to receive(:open).and_yield(write_double)
      allow(write_double).to receive(:write)

      subject.render_file(file)
    end

    it 'reads source' do
      expect(File).to have_received(:read).with(source_path)
    end

    it 'writes rendered template' do
      expect(write_double).to have_received(:write).with(expected_output)
    end

    context 'when a variable is missing' do
      let(:vars) { Hashie::Mash.new }
      let(:var_value) { '' }

      it 'renders template with blank' do
        expect(write_double).to have_received(:write).with(expected_output)
      end
    end
  end

  describe '#copy_file' do
    let(:source_path) { 'path/to/template/file' }
    let(:dest_path) { 'path/to/destination/file' }
    let(:file) { AppArchetype::File.new(source_path, dest_path) }
    let(:exists) { false }

    before do
      allow(FileUtils).to receive(:cp)
      allow(file).to receive(:exist?).and_return(exists)
    end

    it 'copies file' do
      subject.copy_file(file)
      expect(FileUtils).to have_received(:cp).with(source_path, dest_path)
    end

    context 'when file already exists and overwrite not allowed' do
      let(:exists) { true }

      it 'raises error' do
        expect do
          subject.copy_file(file)
        end.to raise_error('cannot overwrite file')
      end
    end

    context 'when file already exists and overwrite is allowed' do
      let(:exists) { true }
      let(:overwrite) { true }

      it 'raises error' do
        expect do
          subject.copy_file(file)
        end.not_to raise_error
      end
    end
  end
end