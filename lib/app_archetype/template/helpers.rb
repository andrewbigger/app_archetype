module AppArchetype
  module Template
    # Template rendering helpers
    module Helpers
      # dot provides a convenient way for a noop render at the
      # beginning of dotfiles
      def dot
        ''
      end

      ##
      # Generates a random string at specified length
      #
      # @param [String] length
      def random_string(length = '256')
        length = length.to_i
        key_set = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
        (0...length).map { key_set[Random.rand(0..key_set.length)] }.join
      end

      ##
      # Randomizes a given string by addding a slice of a hex
      # to the end of it at the specified size.
      #
      # The template will pass through a string as arguments for this
      # function, thus it must accept a string as an argument.
      #
      # @param [String] string
      # @param [String] size
      #
      # @return [String]
      def randomize(string, size = '5')
        size = size.to_i
        raise 'size must be an integer' unless size.is_a?(Integer) && size != 0
        raise 'randomize supports up to 32 characters' if size > 32

        hex = SecureRandom.hex
        suffix = hex[hex.length - size..hex.length]

        "#{string}_#{suffix}"
      end

      ##
      # Converts a string to upper case
      #
      # @param [String] string
      # 
      # @return [String]
      #
      def upcase(string)
        string.upcase
      end

      ##
      # Converts a string to lower case
      #
      # @param [String] string
      #
      # @return [String]
      def downcase(string)
        string.downcase
      end

      ##
      # Joins a string with specified delimiter
      #
      # @param [String] delimiter
      # @param [Array] strings to join
      #
      # @return [String]
      def join(delim, *strings)
        strings.join(delim)
      end

      ##
      # Downcases and substitutes space in a string with underscores. 
      # This is useful for turning a Title into a function name from
      # a manifest variable definition.
      #
      # @example
      #   str = 'A string with     space'
      #   puts underscore(str) # => outputs 'a_string_with_____space'
      #
      # @param [String] string
      #
      # @return [String]
      #
      def underscore(string)
        string
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .tr(' ', '_')
          .downcase
      end

      ##
      # Changes a pascal case strring into camel case. Useful for 
      # converting class names to function or file names.
      #
      # @example
      #   str = 'AGreatExample'
      #   puts camel_case(str) # => outputs 'a_great_example'
      #
      # @param [String] string
      #
      # @return [String]
      #
      def camel_case(string)
        return string.downcase if string =~ /\A[A-Z]+\z/

        string
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z])([A-Z])/, '\1_\2')
          .downcase
      end

      ##
      # Downcase and converts a camel case string into dashcase
      #
      # @example
      #   str = 'AGreatExample'
      #   puts = dash_case(str) # => outputs 'a-great-example'

      def dash_case(string)
        return string.downcase if string =~ /\A[A-Z]+\z/

        string
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
          .gsub(/([a-z])([A-Z])/, '\1-\2')
          .tr(' ', '-')
          .downcase
      end
    end
  end
end
