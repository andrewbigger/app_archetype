require 'ostruct'
require 'json'

module AppArchetype
  module Template
    # Variable is a class representing a single variable
    class Variable
      ##
      # Default variable type (String)
      #
      DEFAULT_TYPE = 'string'.freeze

      ##
      # Default value map
      #
      DEFAULT_VALUES = {
        'string' => '',
        'boolean' => false,
        'integer' => 0
      }.freeze

      ##
      # String validation function. Ensures given input
      # is indeed a string.
      #
      # @param [Object] input
      #
      # @return [Boolean]
      #
      STRING_VALIDATOR = lambda do |input|
        input.is_a?(String)
      end

      ##
      # Boolean validation function. Ensures given input
      # is a boolean.
      #
      # @param [Object] input
      #
      # @return [Boolean]
      #
      BOOLEAN_VALIDATOR = lambda do |input|
        [true, false].include?(input)
      end

      ##
      # Integer validation function. Ensures given input is
      # an integer.
      #
      # @param [Object] input
      #
      # @return [Boolean]
      #
      INTEGER_VALIDATOR = lambda do |input|
        input != '0' && input.to_i != 0
      end

      ##
      # Maps type to validation function
      #
      VALIDATORS = {
        'string' => STRING_VALIDATOR,
        'boolean' => BOOLEAN_VALIDATOR,
        'integer' => INTEGER_VALIDATOR
      }

      ##
      # Default validation function (string validator)
      #
      DEFAULT_VALIDATOR = STRING_VALIDATOR

      attr_reader :name

      def initialize(name, spec)
        @name = name
        @spec = OpenStruct.new(spec)
        @value = @spec.value
      end

      ##
      # Sets value of variable so long as it's valid.
      #
      # A runtime error will be raised if the valdiation
      # fails for the given value.
      #
      # Has a side effect of setting @value instance variable
      #
      # @param [Object] value
      def set!(value)
        raise 'invalid value' unless valid?(value)

        @value = value
      end

      ##
      # Returns default value for the variable.
      #
      # In the event the manifest does not specify a default
      # one will be picked from the DEFAULT_VALUES map based on
      # the variable's type.
      #
      # @return [Object]
      #
      def default
        return DEFAULT_VALUES[type] unless @spec.default

        @spec.default
      end

      ##
      # Returns variable description.
      #
      # In the event the manifest does not specify a description
      # an empty string will be returned.
      #
      # @return [String]
      #
      def description
        return '' unless @spec.description

        @spec.description
      end

      ##
      # Returns variable type.
      #
      # In the event the manifest does not specify a type, the
      # default type of String will be returned.
      #
      # @return [String]
      #
      def type
        return DEFAULT_TYPE unless @spec.type

        @spec.type
      end

      ##
      # Returns variable value.
      # 
      # If the value has not been set (i.e. overridden) then the
      # default value will be returned.
      #
      # Values set beginning with `#` are passed into the helpers 
      # class and evaluated as functions. That permits the manifest 
      # to use string helpers as values from the manifest.
      #
      # Function calls must be in the format `#method_name,arg1,arg2`
      # for example to call the join function `#join,.,biggerconcept,com`
      # will result in `biggerconcept.com` becoming the value.
      #
      # @return [String]
      #
      def value
        return default if @value.nil?
        return call_helper if method?

        @value
      end

      ##
      # Returns true if value has been set
      #
      # @return [Boolean]
      def value?
        !@value.nil?
      end

      ##
      # Retrieves the appropriate validator function basedd on the 
      # specified type.
      #
      # If a type is not set then a string validator function is 
      # returned by default
      #
      # @return [Proc]
      #
      def validator
        validator = VALIDATORS[@spec.type]
        validator ||= DEFAULT_VALIDATOR

        validator
      end

      ##
      # Returns true if the value input is valid.
      #
      # @param [String] input
      #
      # @return [Boolean]
      #
      def valid?(input)
        validator.call(input)
      end

      private

      # Returns an object which extends helpers module.
      #
      # This is used for calling helper functions
      def helpers
        Object
          .new
          .extend(AppArchetype::Template::Helpers)
      end

      # Returns true if variable value begins with `#` this
      # indicates the variable value has been set to a function
      def method?
        return false unless @value.is_a?(String)
        @value[0, 1] == '#'
      end

      # Calls a helper function to generate a value
      def call_helper
        method = deserialize_method(@value)
        helpers.send(method.name, *method.args)
      end

      # Creates a struct representing a method call to be made
      # to resolve a variable value
      def deserialize_method(method)
        method = method.delete('#')
        parts = method.split(',')
        name = parts.shift

        args = parts || []

        OpenStruct.new(
          name: name.to_sym,
          args: args
        )
      end
    end
  end
end
