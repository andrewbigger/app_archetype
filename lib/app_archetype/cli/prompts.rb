require 'highline'

module AppArchetype
  class CLI < Thor
    # CLI output presenters
    module Prompts
      ##
      # Variable prompt question. Asked when evaluating template
      # variables
      #
      # @param [AppArchetype::Template::Variable] variable
      #
      # @return [Proc]
      #
      VAR_PROMPT_MESSAGE = lambda do |variable|
        "\nEnter value for `#{variable.name}` variable\n\n"\
        "DESCRIPTION: #{variable.description}\n"\
        "TYPE: #{variable.type}\n"\
        "DEFAULT: #{variable.default}"
      end

      class <<self
        ##
        # Prompt returns a TTY prompt object for asking the user
        # questions.
        #
        # @return [HighLine]
        def prompt
          HighLine.new
        end

        ##
        # A yes/no prompt for asking the user a yes or no question.
        #
        # @return [Boolean]
        #
        def yes?(message)
          prompt.ask("#{message} [Y/n]", String) { |input| input.strip == 'Y' }
        end

        ##
        # Prompt for requesting user input.
        #
        # A default can be provided in the event the user does not
        # provide an answer.
        #
        # Validator also performs type conversion by default it is
        # a string
        #
        # @param message [String]
        # @param default [Object]
        # @param validator [Object|Lambda]
        #
        # @return [Object]
        #
        def ask(message, validator: String, default: nil)
          resp = prompt.ask(message, validator)
          return default if !default.nil? && resp.to_s.empty?

          resp
        end

        ##
        # Y/N prompt to ensure user is sure they wish to delete
        # the selected template
        #
        # @param [AppArchetype::Template::Manifest] manifest
        #
        # @return [Boolean]
        def delete_template(manifest)
          yes?(
            "Are you sure you want to delete `#{manifest.name}`?"
          )
        end

        ##
        # Returns a variable prompt based on the type of variable
        # required. Once prompt has been executed, the response is
        # returned to the caller.
        #
        # When the value is set in the manifest, the set value is
        # returned without a prompt.
        #
        # For boolean and integer variables, the relevant prompt
        # function is called.
        #
        # By default the string variable prompt will be used.
        #
        # @param [AppArchetype::Template::Variable] var
        #
        # @return [Object]
        #
        def variable_prompt_for(var)
          return var.value if var.value?
          return boolean_variable_prompt(var) if var.type == 'boolean'
          return integer_variable_prompt(var) if var.type == 'integer'

          string_variable_prompt(var)
        end

        ##
        # Prompt for boolean variable. This quizzes the user as to
        # whether they want the variable set or not. The response
        # is returned to the caller.
        #
        # @param [AppArchetype::Template::Variable] variable
        #
        # @return [Boolean]
        #
        def boolean_variable_prompt(variable)
          yes?(
            VAR_PROMPT_MESSAGE.call(variable)
          )
        end

        ##
        # Prompt for integer. This quizzes the user for their
        # choice and then attempts to convert it to an integer.
        #
        # In the event a non integer value is entered, a
        # RuntimeError is thrown.
        #
        # @param [AppArchetype::Template::Variable] variable
        #
        # @return [Integer]
        #
        def integer_variable_prompt(variable)
          ask(
            VAR_PROMPT_MESSAGE.call(variable),
            default: variable.default,
            validator: Integer
          )
        end

        ##
        # Prompt for a string. Asks user for input and returns
        # it.
        #
        # @param [AppArchetype::Template::Variable] variable
        #
        # @return [String]
        #
        def string_variable_prompt(variable)
          ask(
            VAR_PROMPT_MESSAGE.call(variable),
            default: variable.default
          )
        end
      end
    end
  end
end
