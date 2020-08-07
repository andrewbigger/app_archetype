require 'spec_helper'

RSpec.describe AppArchetype::Template::VariableManager do
  let(:var_name) { 'example_string' }
  let(:var_type) { 'string' }
  let(:var_desc) { 'This is an example string variable' }
  let(:var_default) { 'default value' }
  let(:var_value) { 'set value' }

  let(:variables_spec) do
    {
      var_name => {
        'type' => var_type,
        'description' => var_desc,
        'default' => var_default
      },
      "#{var_name}_with_value" => {
        'type' => var_type,
        'description' => var_desc,
        'default' => var_default,
        'value' => var_value
      },
      'example_random_string' => {
        'type' => 'string',
        'description' => 'Example call to helper to generate 25 char string',
        'value' => '#random_string,25'
      }
    }
  end

  subject { described_class.new(variables_spec) }

  describe '#all' do
    it 'returns array of template variables' do
      expect(subject.all).to all(be_a AppArchetype::Template::Variable)
    end

    it 'has expected variables' do
      expect(subject.all.map(&:name))
        .to eq(
          [
            'example_string', 
            'example_string_with_value',
            'example_random_string'
          ]
        )
    end
  end

  describe '#get' do
    before { @var = subject.get(var_name) }

    it 'returns variable' do
      expect(@var.name).to eq var_name
      expect(@var.type).to eq var_type
      expect(@var.description).to eq var_desc
      expect(@var.default).to eq var_default
    end
  end

  describe '#to_h' do
    let(:instance_helpers) { double }
    let(:random_result) { 'random-string-25-chars-long' }

    before do
      allow_any_instance_of(AppArchetype::Template::Variable)
        .to receive(:helpers)
        .and_return(instance_helpers)

      allow(instance_helpers)
        .to receive(:random_string)
        .and_return(random_result)
    end

    it 'returns hash representation of variables (key => value)' do
      expect(subject.to_h).to eq(
        var_name => var_default,
        "#{var_name}_with_value" => var_value,
        'example_random_string' => random_result
      )
    end
  end

  describe '#method_missing' do
    context 'when variable is defined without value' do
      it 'returns default variable value' do
        expect(subject.example_string).to eq var_default
      end
    end

    context 'when variable is defined with a value' do
      it 'returns set variable value' do
        expect(subject.example_string_with_value).to eq var_value
      end
    end

    context 'when variable is not defined' do
      it 'raises NoMethodError' do
        expect { subject.foo }.to raise_error(NoMethodError)
      end
    end
  end
end
