require 'ostruct'
require 'json'

module AppArchetype
  module Template
    # Manages a collection of variables
    class VariableManager
      def initialize(vars)
        vars ||= []
        @data = []

        vars.each do |name, spec|
          @data << AppArchetype::Template::Variable.new(name, spec)
        end
      end

      ##
      # Returns all variables managed by the variable manager.
      #
      # @return [Array]
      #
      def all
        @data
      end

      ##
      # Retrieves a variable by name from the variable manager.
      #
      # @param [String] name
      #
      # @return [AppArchetype::Template::Variable]
      #
      def get(name)
        @data.detect { |var| var.name == name }
      end

      ##
      # Creates a hash representation of variables.
      #
      # The variable name is the key, and the currrent value
      # is the value.
      #
      # @return [Hash]
      #
      def to_h
        var_hash = {}

        @data.each do |var|
          var_hash[var.name] = var.value
        end

        var_hash
      end

      ##
      # Method missing retrieves variable from manager and
      # returns the value to the caller if it is found.
      #
      # When a call is made to an undefined variable, a
      # MethodMissing error will be raised.
      #
      # @params [Symbol] method
      # @params [Array] args
      #
      # @return [Object]
      #
      def method_missing(method, *args)
        var = get(method.to_s)
        return var.value if var

        super
      end
    end
  end
end
