require 'spec_helper'

RSpec.describe AppArchetype::Commands::NewTemplate do
  let(:template_dir) { 'path/to/templates' }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(template_dir, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:template_name) { 'new-template' }
    let(:out_dir) { File.join(template_dir, template_name) }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(AppArchetype::Generators)
        .to receive(:render_empty_template)
      allow(subject).to receive(:puts)
    end

    context 'when template name is provided' do
      let(:options) do
        Hashie::Mash.new(
          name: template_name
        )
      end

      before { subject.run }

      it 'makes the folder' do
        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(out_dir)
      end

      it 'generates the empty template' do
        expect(AppArchetype::Generators)
          .to have_received(:render_empty_template)
          .with(template_name, out_dir)
      end

      it 'prints success message' do
        expect(subject)
          .to have_received(:puts)
          .with("✔ Template `#{template_name}` created at #{out_dir}")
      end
    end

    context 'when template name is not provided' do
      before do
        allow(prompt).to receive(:ask).and_return(template_name)
        subject.run
      end

      it 'prompts user for a new name' do
        expect(prompt)
          .to have_received(:ask)
          .with('Please enter a name for the new template')
      end

      it 'makes the folder' do
        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(out_dir)
      end

      it 'generates the empty template' do
        expect(AppArchetype::Generators)
          .to have_received(:render_empty_template)
          .with(template_name, out_dir)
      end

      it 'prints success message' do
        expect(subject)
          .to have_received(:puts)
          .with("✔ Template `#{template_name}` created at #{out_dir}")
      end
    end
  end
end
