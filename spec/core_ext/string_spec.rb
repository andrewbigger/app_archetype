require 'spec_helper'

RSpec.describe String do
  subject { 'AnInterestingString' }

  describe '#snake_case' do
    context 'given a pascal case string' do
      it 'converts string to camel case' do
        expect(subject.snake_case).to eq 'an_interesting_string'
      end
    end

    context 'given a title case string' do
      subject { 'An Interesting String' }

      it 'converts string to camel case' do
        expect(subject.snake_case).to eq 'an_interesting_string'
      end
    end

    context 'given a dash case string' do
      subject { 'An-Interesting String' }

      it 'converts string to camel case' do
        expect(subject.snake_case).to eq 'an_interesting_string'
      end
    end
  end

  describe '#dash_case' do
    context 'given a pascal case string' do
      it 'converts string to dash case' do
        expect(subject.dash_case).to eq 'an-interesting-string'
      end
    end

    context 'given a title case string' do
      subject { 'An Interesting String' }

      it 'converts string to camel case' do
        expect(subject.dash_case).to eq 'an-interesting-string'
      end
    end

    context 'given a camel case string' do
      subject { 'an_interesting_string' }

      it 'converts string to camel case' do
        expect(subject.dash_case).to eq 'an-interesting-string'
      end
    end
  end

  describe '#randomize' do
    let(:hex) { '9fec9b4d7c8cd121bfe5a4f7e31eb499' }

    before do
      allow(SecureRandom).to receive(:hex).and_return(hex)
    end

    it 'adds random 5 letter string onto the end' do
      expect(subject.randomize).to eq 'AnInterestingString_eb499'
    end

    context 'when length is set' do
      it 'adds random 10 letter string ont the end' do
        expect(subject.randomize(10)).to eq 'AnInterestingString_f7e31eb499'
      end
    end
  end
end
