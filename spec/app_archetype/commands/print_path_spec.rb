require 'spec_helper'

RSpec.describe AppArchetype::Commands::PrintPath do
  let(:options) { Hashie::Mash.new }
  let(:template_dir) { '/path/to/templates' }

  subject { described_class.new(template_dir, options) }

  before do
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    before { subject.run }

    it 'prints given template path to STDOUT' do
      expect(subject)
        .to have_received(:puts)
        .with(template_dir)
    end
  end
end
