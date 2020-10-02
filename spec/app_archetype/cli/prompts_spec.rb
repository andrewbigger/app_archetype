require 'spec_helper'

RSpec.describe AppArchetype::CLI::Prompts do
  let(:var_name) { 'foo' }
  let(:var_type) { 'string' }
  let(:var_desc) { 'a foo' }
  let(:var_default) { 'bar' }
  let(:var_value) { nil }

  let(:variable) do
    double(
      AppArchetype::Template::Variable,
      name: var_name,
      description: var_desc,
      type: var_type,
      default: var_default,
      value: var_value
    )
  end

  describe '::VAR_PROMPT_MESSAGE' do
    before do
      @prompt = described_class::VAR_PROMPT_MESSAGE.call(variable)
    end

    it 'displays prompt' do
      expect(
        @prompt.include?("Enter value for `#{var_name}` variable")
      ).to be true
    end

    it 'displays variable description' do
      expect(@prompt.include?("DESCRIPTION: #{var_desc}")).to be true
    end

    it 'displays variable type' do
      expect(@prompt.include?("TYPE: #{var_type}")).to be true
    end

    it 'displays variable default' do
      expect(@prompt.include?("DEFAULT: #{var_default}")).to be true
    end
  end

  describe '.prompt' do
    it 'returns a prompt' do
      expect(described_class.prompt).to be_a(HighLine)
    end
  end

  describe '.yes?' do
    let(:prompt) { double(HighLine) }
    let(:message) { 'Would you like to do stuff?' }
    let(:response) { 'Y' }

    before do
      allow(subject).to receive(:prompt).and_return(prompt)
      allow(prompt).to receive(:ask).and_yield(response)

      @resp = subject.yes?(message)
    end

    it 'asks question' do
      expect(prompt).to have_received(:ask).with("#{message} [Y/n]", String)
    end

    it 'returns true when user responds Y' do
      expect(@resp).to be true
    end

    context 'when user inputs anything other than Y' do
      let(:response) { 'Nope' }

      it 'returns false' do
        expect(@resp).to be false
      end
    end
  end

  describe '.ask' do
    let(:prompt) { double(HighLine) }

    let(:message) { 'Give me some info' }
    let(:validator) { String }
    let(:default) { 'Default' }

    let(:response) { 'Sure here it is' }

    before do
      allow(subject).to receive(:prompt).and_return(prompt)
      allow(prompt).to receive(:ask).and_return(response)

      @resp = subject.ask(message, validator: validator, default: default)
    end

    it 'asks question with validator' do
      expect(prompt).to have_received(:ask).with(message, validator)
    end

    it 'returns user response as string' do
      expect(@resp).to eq response
    end

    context 'when default is specifed and empty response' do
      let(:response) { '' }

      it 'returns default' do
        expect(@resp).to eq default
      end
    end

    context 'when empty and no default specified' do
      let(:default) { nil }
      let(:response) { '' }

      it 'returns empty string' do
        expect(@resp).to eq ''
      end
    end

    context 'when asking for an integer' do
      let(:response) { 1 }
      let(:validator) { Integer }

      it 'returns user response as integer' do
        expect(@resp).to eq 1
      end
    end
  end

  describe '.delete_template' do
    let(:prompt) { double(HighLine) }

    let(:manifest_name) { 'test_manifest' }
    let(:manifest) do
      double(AppArchetype::Template::Manifest, name: manifest_name)
    end

    let(:choice) { false }

    before do
      allow(subject).to receive(:prompt).and_return(prompt)
      allow(subject).to receive(:yes?).and_return(choice)

      @result = described_class.delete_template(manifest)
    end

    it 'asks if it is okay to delete template' do
      expect(subject).to have_received(:yes?)
        .with('Are you sure you want to delete `test_manifest`?')
    end

    it 'returns user choice' do
      expect(@result).to eq choice
    end
  end

  describe '.variable_prompt_for' do
    let(:has_value) { false }

    before do
      allow(variable).to receive(:value?).and_return(has_value)

      allow(described_class).to receive(:boolean_variable_prompt)
      allow(described_class).to receive(:integer_variable_prompt)
      allow(described_class).to receive(:string_variable_prompt)
    end

    context 'when variable value is set' do
      let(:has_value) { true }
      let(:var_value) { 'some-value' }

      it 'returns value' do
        expect(
          described_class.variable_prompt_for(variable)
        ).to eq var_value
      end
    end

    context 'when variable type is a boolean' do
      let(:var_type) { 'boolean' }

      before { described_class.variable_prompt_for(variable) }

      it 'calls boolean variable prompt' do
        expect(described_class)
          .to have_received(:boolean_variable_prompt)
          .with(variable)
      end
    end

    context 'when variable type is an integer' do
      let(:var_type) { 'integer' }

      before { described_class.variable_prompt_for(variable) }

      it 'calls integer variable prompt' do
        expect(described_class)
          .to have_received(:integer_variable_prompt)
          .with(variable)
      end
    end

    context 'when variable type is a string' do
      let(:var_type) { 'string' }

      before { described_class.variable_prompt_for(variable) }

      it 'calls string variable prompt' do
        expect(described_class)
          .to have_received(:string_variable_prompt)
          .with(variable)
      end
    end

    context 'treats variables as strings by default' do
      let(:var_type) { nil }

      before { described_class.variable_prompt_for(variable) }

      it 'calls string variable prompt' do
        expect(described_class)
          .to have_received(:string_variable_prompt)
          .with(variable)
      end
    end
  end

  describe '.boolean_variable_prompt' do
    let(:choice) { false }

    before do
      allow(subject).to receive(:yes?).and_return(choice)
      @result = described_class.boolean_variable_prompt(variable)
    end

    it 'asks for boolean input' do
      expect(subject).to have_received(:yes?)
        .with(
          AppArchetype::CLI::Prompts::VAR_PROMPT_MESSAGE.call(variable)
        )
    end

    it 'returns user choice' do
      expect(@result).to eq choice
    end
  end

  describe '.integer_variable_prompt' do
    let(:choice) { 1 }

    before do
      allow(subject).to receive(:ask).and_return(choice)
      @result = described_class.integer_variable_prompt(variable)
    end

    it 'asks for boolean input' do
      expect(subject).to have_received(:ask)
        .with(
          AppArchetype::CLI::Prompts::VAR_PROMPT_MESSAGE.call(variable),
          default: variable.default,
          validator: Integer
        )
    end

    it 'returns user choice' do
      expect(@result).to eq choice
    end
  end

  describe '.string_variable_prompt' do
    let(:choice) { 'some string' }

    before do
      allow(subject).to receive(:ask).and_return(choice)

      @result = described_class.string_variable_prompt(variable)
    end

    it 'asks for boolean input' do
      expect(subject).to have_received(:ask)
        .with(
          AppArchetype::CLI::Prompts::VAR_PROMPT_MESSAGE.call(variable),
          default: variable.default
        )
    end

    it 'returns user choice' do
      expect(@result).to eq choice
    end
  end
end
