require 'hashie'
require 'json'

module AppArchetype
  # Variables is a module for parsing variables for use in templates
  class Variables < Hashie::Mash
    # dot provides a convenient way for a noop render at the
    # beginning of dotfiles
    def dot
      ''
    end

    ##
    # rand
    #
    # generates a random string at specified length
    #
    # @param length - size of string
    def rand(length = 256)
      key_set = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
      (0...length).map { key_set[Random.rand(0..key_set.length)] }.join
    end
  end
end
