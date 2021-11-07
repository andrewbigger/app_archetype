require 'spec_helper'

RSpec.describe AppArchetype::Commands::RenderTemplate do
  let(:manager) { double(AppArchetype::TemplateManager) }
  let(:destination_path) { 'path/to/output' }
  let(:options) { Hashie::Mash.new }
  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, destination_path, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)

    allow(subject).to receive(:puts)
    allow(prompt).to receive(:ask)
    allow(prompt).to receive(:yes?)
    allow(prompt).to receive(:select)
  end

  describe '#run' do
    let(:manifest_names) { %s( manifest1 manifest2 ) }
    let(:manifest_name) { 'some-manifest' }
    let(:template) { double(AppArchetype::Template) }
    let(:overwrite) { true }

    context 'when a name is provided in options' do
      let(:options) do
        Hashie::Mash.new(
          name: manifest_name,
          overwrite: overwrite
        )
      end

      let(:manifest) { double(AppArchetype::Template::Manifest) }

      before do
        allow(manager)
          .to receive(:find_by_name)
          .and_return(manifest)

        allow(manifest).to receive(:template).and_return(template)
        allow(template).to receive(:load)
        allow(subject).to receive(:resolve_variables)
        allow(subject).to receive(:render_template)
        allow(subject).to receive(:puts)

        subject.run
      end

      describe 'and template is found' do
        it 'finds template by name' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'loads the template' do
          expect(template)
            .to have_received(:load)
        end

        it 'resolves variables' do
          expect(subject)
            .to have_received(:resolve_variables)
            .with(manifest)
        end

        it 'renders template' do
          expect(subject)
            .to have_received(:render_template)
            .with(
              manifest,
              template,
              overwrite: overwrite
            )
        end

        it 'prints success message' do
          expect(subject)
            .to have_received(:puts)
            .with("✔ Rendered #{manifest_name} to #{destination_path}")
        end
      end

      describe 'when template is not found' do
        let(:manifest) { nil }

        it 'attempts to find the template by name' do
          expect(manager)
            .to have_received(:find_by_name)
            .with(manifest_name)
        end

        it 'prints no template found message' do
          expect(subject)
            .to have_received(:puts)
            .with("✖ No template with name `#{manifest_name}` found.")
        end

        it 'does not resolve variables' do
          expect(subject)
            .not_to have_received(:resolve_variables)
        end

        it 'does not render template' do
          expect(subject)
            .not_to have_received(:render_template)
        end
      end
    end

    context 'when name is not provided in options' do
      let(:options) do
        Hashie::Mash.new(
          overwrite: overwrite
        )
      end

      let(:manifest) { double(AppArchetype::Template::Manifest) }

      before do
        allow(prompt).to receive(:select).and_return(manifest_name)
        allow(manager)
          .to receive(:manifest_names)
          .and_return(manifest_names)

        allow(manager)
          .to receive(:find_by_name)
          .and_return(manifest)

        allow(manifest).to receive(:template).and_return(template)
        allow(template).to receive(:load)
        allow(subject).to receive(:resolve_variables)
        allow(subject).to receive(:render_template)
        allow(subject).to receive(:puts)

        subject.run
      end

      it 'prompts user to select their manifest from a list' do
        expect(prompt)
          .to have_received(:select)
          .with('Please choose manifest', manifest_names)
      end

      it 'loads the template' do
        expect(template)
          .to have_received(:load)
      end

      it 'resolves variables' do
        expect(subject)
          .to have_received(:resolve_variables)
          .with(manifest)
      end

      it 'renders template' do
        expect(subject)
          .to have_received(:render_template)
          .with(
            manifest,
            template,
            overwrite: overwrite
          )
      end

      it 'prints success message' do
        expect(subject)
          .to have_received(:puts)
          .with("✔ Rendered #{manifest_name} to #{destination_path}")
      end
    end
  end

  describe '#resolve_variables' do
    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:variable_manager) { double(AppArchetype::Template::VariableManager) }
    let(:variable) { double(AppArchetype::Template::Variable) }
    let(:variables) { [variable, variable] }
    let(:prompt_response) { 'some-value' }

    before do
      allow(manifest).to receive(:variables).and_return(variable_manager)
      allow(variable_manager).to receive(:all).and_return(variables)
      allow(subject).to receive(:variable_prompt_for).and_return(prompt_response)
      allow(variable).to receive(:set!)

      subject.resolve_variables(manifest)
    end

    it 'executes the variable prompt for each variable' do
      expect(subject)
        .to have_received(:variable_prompt_for)
        .with(variable)
        .twice
    end

    it 'sets the variable with the prompt result' do
      expect(variable)
        .to have_received(:set!)
        .with(prompt_response)
        .twice
    end
  end

  describe '#render_template' do
    let(:manifest) { double(AppArchetype::Template::Manifest) }
    let(:template) { double(AppArchetype::Template) }
    let(:variables) { double(AppArchetype::Template::VariableManager) }
    let(:plan) { double(AppArchetype::Template::Plan) }

    before do
      allow(manifest).to receive(:variables)
        .and_return(variables)

      allow(plan).to receive(:devise)
      allow(plan).to receive(:execute)

      allow(AppArchetype::Template::Plan)
        .to receive(:new)
        .and_return(plan)

      subject.render_template(
        manifest,
        template
      )
    end

    it 'constructs a plan' do
      expect(AppArchetype::Template::Plan)
        .to have_received(:new)
        .with(template, variables, destination_path: destination_path, overwrite: false)
    end

    it 'devises the plan' do
      expect(plan).to have_received(:devise)
    end

    it 'executes the plan' do
      expect(plan).to have_received(:execute)
    end
  end

  describe '#variable_prompt_for' do
    let(:bool_prompt_resp) { true }
    let(:int_prompt_resp) { 3 }
    let(:str_prompt_resp) { 'resp' }

    before do
      allow(subject)
        .to receive(:boolean_variable_prompt_for)
        .and_return(bool_prompt_resp)

      allow(subject)
        .to receive(:integer_variable_prompt_for)
        .and_return(int_prompt_resp)

      allow(subject)
        .to receive(:string_variable_prompt_for)
        .and_return(str_prompt_resp)
    end

    context 'when variable is set' do
      let(:set_variable) do
        AppArchetype::Template::Variable.new(
          'string',
          {
            name: 'string',
            description: 'a string',
            value: 'already-set',
            type: 'string'
          }
        )
      end

      before do
        @resp = subject.variable_prompt_for(set_variable)
      end

      it 'returns set value' do
        expect(@resp).to eq 'already-set'
      end
    end

    context 'when variable is a boolean type' do
      let(:variable) do
        AppArchetype::Template::Variable.new(
          'boolean',
          {
            name: 'bool',
            description: 'a boolean',
            default: false,
            type: 'boolean'
          }
        )
      end

      before do
        @resp = subject.variable_prompt_for(variable)
      end

      it 'returns a boolean prompt for the variable' do
        expect(subject).to have_received(:boolean_variable_prompt_for).with(variable)
      end

      it 'returns prompt response' do
        expect(@resp).to eq bool_prompt_resp
      end
    end

    context 'when variable is integer type' do
      let(:variable) do
        AppArchetype::Template::Variable.new(
          'integer',
          {
            name: 'int',
            description: 'a integer',
            default: 2,
            type: 'integer'
          }
        )
      end

      before do
        @resp = subject.variable_prompt_for(variable)
      end

      it 'returns a integer prompt for the variable' do
        expect(subject).to have_received(:integer_variable_prompt_for).with(variable)
      end

      it 'returns prompt response' do
        expect(@resp).to eq int_prompt_resp
      end
    end

    context 'when variable is string type' do
      let(:variable) do
        AppArchetype::Template::Variable.new(
          'string',
          {
            name: 'string',
            description: 'a string',
            default: false,
            type: 'string'
          }
        )
      end

      before do
        @resp = subject.variable_prompt_for(variable)
      end

      it 'returns a string prompt for the variable' do
        expect(subject).to have_received(:string_variable_prompt_for).with(variable)
      end

      it 'returns prompt response' do
        expect(@resp).to eq str_prompt_resp
      end
    end
  end

  describe '#boolean_variable_prompt_for' do
    let(:variable_name) { 'some-boolean' }
    let(:variable_description) { 'A test boolean' }
    let(:variable_default) { true }

    let(:variable_spec) do
      {
        name: variable_name,
        description: variable_description,
        default: variable_default
      }
    end

    let(:variable) do
      AppArchetype::Template::Variable.new(
        variable_name,
        variable_spec
      )
    end

    before do
      subject.boolean_variable_prompt_for(variable)
    end

    it 'prints boolean prompt message' do
      expect(subject).to have_received(:puts)
        .with("• #{variable_name} (#{variable_description})")
    end

    it 'asks for boolean value for variable' do
      expect(prompt).to have_received(:yes?)
        .with(
          "Enter value for `#{variable_name}` variable:",
          default: variable_default
        )
    end
  end

  describe '#integer_variable_prompt_for' do
    let(:variable_name) { 'some-integer' }
    let(:variable_description) { 'A test integer' }
    let(:variable_default) { 1 }

    let(:variable_spec) do
      {
        name: variable_name,
        description: variable_description,
        default: variable_default
      }
    end

    let(:variable) do
      AppArchetype::Template::Variable.new(
        variable_name,
        variable_spec
      )
    end

    before do
      subject.integer_variable_prompt_for(variable)
    end

    it 'prints integer prompt message' do
      expect(subject).to have_received(:puts)
        .with("• #{variable_name} (#{variable_description})")
    end

    it 'asks for integer value for variable' do
      expect(prompt)
        .to have_received(:ask)
        .with(
          "Enter value for `#{variable_name}` variable:",
          convert: :int,
          default: variable_default
        )
    end
  end

  describe '#string_variable_prompt_for' do
    let(:variable_name) { 'some-string' }
    let(:variable_description) { 'A test string' }
    let(:variable_default) { 'default string' }

    let(:variable_spec) do
      {
        name: variable_name,
        description: variable_description,
        default: variable_default
      }
    end

    let(:variable) do
      AppArchetype::Template::Variable.new(
        variable_name,
        variable_spec
      )
    end

    before do
      subject.string_variable_prompt_for(variable)
    end

    it 'prints string prompt message' do
      expect(subject).to have_received(:puts)
        .with("• #{variable_name} (#{variable_description})")
    end

    it 'asks for string value for message' do
      expect(prompt).to have_received(:ask)
        .with(
          "Enter value for `#{variable_name}` variable:",
          default: variable_default
        )
    end
  end
end
