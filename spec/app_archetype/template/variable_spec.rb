require 'spec_helper'

RSpec.describe AppArchetype::Template::Variable do
  let(:description) { 'explanation of variable' }
  let(:type) { 'string' }
  let(:default) { 'default-value' }
  let(:value) { nil }

  let(:name) { 'var' }
  let(:spec) do
    {
      'description' => description,
      'type' => type,
      'default' => default,
      'value' => value
    }
  end

  subject { described_class.new(name, spec) }

  describe '::STRING_VALIDATOR' do
    it 'returns true when given string input' do
      expect(
        described_class::STRING_VALIDATOR.call('this is string')
      ).to be true
    end

    it 'returns false when given non string input' do
      expect(
        described_class::STRING_VALIDATOR.call(1)
      ).to be false
    end
  end

  describe '::BOOLEAN_VALIDATOR' do
    it 'returns true when given boolean input' do
      expect(
        described_class::BOOLEAN_VALIDATOR.call(true)
      ).to be true
    end

    it 'returns true when given string representation of boolean input' do
      expect(
        described_class::BOOLEAN_VALIDATOR.call('true')
      ).to be true
    end

    it 'returns false when given non boolean input' do
      expect(
        described_class::BOOLEAN_VALIDATOR.call('not bool')
      ).to be false
    end
  end

  describe '::INTEGER_VALIDATOR' do
    it 'returns true when given integer input' do
      expect(
        described_class::INTEGER_VALIDATOR.call(1)
      ).to be true
    end

    it 'returns true when given string representation of integer' do
      expect(
        described_class::INTEGER_VALIDATOR.call('1')
      ).to be true
    end

    it 'returns false when given non integer input' do
      expect(
        described_class::INTEGER_VALIDATOR.call('one')
      ).to be false
    end
  end

  describe '#set!' do
    context 'setting with a valid value' do
      before { subject.set!('a value') }

      it 'sets the value of the variable' do
        expect(subject.value).to eq 'a value'
      end
    end

    context 'setting with an invalid value' do
      let(:type) { 'integer' }

      it 'raises invalid value runtime error' do
        expect do
          subject.set!('a string')
        end.to raise_error('invalid value')
      end
    end
  end

  describe '#default' do
    context 'when default is in specification' do
      it 'returns specified default value' do
        expect(subject.default).to eq default
      end
    end

    context 'when default is not specified' do
      let(:spec) do
        {
          'type' => 'integer'
        }
      end

      it 'returns archetype default' do
        expect(subject.default).to eq 0
      end
    end
  end

  describe '#description' do
    context 'when description is in specification' do
      it 'returns specified description value' do
        expect(subject.description).to eq description
      end
    end

    context 'when default is not specified' do
      let(:spec) do
        {
          'type' => 'integer'
        }
      end

      it 'returns empty string' do
        expect(subject.description).to eq ''
      end
    end
  end

  describe '#type' do
    context 'when type is in specification' do
      it 'returns specified type value' do
        expect(subject.type).to eq type
      end
    end

    context 'when default is not specified' do
      let(:spec) do
        {}
      end

      it 'returns string by default' do
        expect(subject.type).to eq 'string'
      end
    end
  end

  describe '#value' do
    context 'when value is not specified' do
      it 'returns default value' do
        expect(subject.value).to eq default
      end
    end

    context 'when value is a function call' do
      let(:helper) { double }
      let(:value) { '#upcase,foo' }

      it 'returns result of function call' do
        expect(subject.value).to eq 'FOO'
      end
    end

    context 'when value has been set' do
      let(:value) { 'some-value' }

      it 'returns variable value' do
        expect(subject.value).to eq value
      end
    end
  end

  describe '#value?' do
    context 'when value is not set' do
      let(:value) { nil }

      it 'returns false' do
        expect(subject.value?).to be false
      end
    end

    let(:value) { 'some-value' }

    context 'when value is set' do
      it 'returns true' do
        expect(subject.value?).to be true
      end
    end
  end

  describe '#validator' do
    context 'when variable type is specified' do
      let(:type) { 'integer' }

      it 'returns validator for specified type' do
        expect(subject.validator)
          .to eq AppArchetype::Template::Variable::INTEGER_VALIDATOR
      end
    end

    context 'when variable type is not specified' do
      let(:type) { nil }

      it 'returns string validator' do
        expect(subject.validator)
          .to eq AppArchetype::Template::Variable::STRING_VALIDATOR
      end
    end
  end

  describe '#valid?' do
    context 'when validator returns true' do 
      let(:result) { true }
      let(:validator) { double(call: result) }

      before do
        allow(subject).to receive(:validator)
          .and_return(validator)
      end

      it 'returns true' do
        expect(subject.valid?('input')).to be true
      end
    end

    context 'when validator returns false' do
      let(:result) { false }
      let(:validator) { double(call: result) }

      before do
        allow(subject).to receive(:validator)
          .and_return(validator)
      end

      it 'returns false' do
        expect(subject.valid?('input')).to be false
      end
    end
  end
end
