require 'spec_helper'

RSpec.describe AppArchetype::Variables do
  subject { described_class.new({}) }

  describe '#dot' do
    it 'returns empty string' do
      expect(subject.dot).to eq ''
    end
  end

  describe 'rand' do
    let(:length) { 12 }

    before do
      @result = subject.rand(length)
    end

    it 'generates string of specified length' do
      expect(@result.length).to eq length
    end

    it 'is random' do
      expect(subject.rand(12)).not_to eq @result
    end
  end
end
