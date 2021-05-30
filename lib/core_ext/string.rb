require 'app_archetype/template/helpers'

# Archetype extensions for String
class String
  ##
  # Converts string to snake case
  #
  # @return [String]
  #
  def snake_case
    helper.snake_case(self)
  end

  ##
  # Converts string to dash case
  #
  # @return [String]
  #
  def dash_case
    helper.dash_case(self)
  end

  ##
  # Converts a string to camel case
  #
  # @return [String]
  #
  def camel_case
    helper.camel_case(self)
  end

  ##
  # Attempts to pluralize a word
  #
  # @return [String]
  #
  def pluralize
    helper.pluralize(self)
  end

  ##
  # Attempts to singluarize a word
  #
  # @return [String]
  #
  def singularize
    helper.singularize(self)
  end

  ##
  # Adds a random string of specified length at the end
  #
  # @return [String]
  #
  def randomize(size = 5)
    helper.randomize(self, size.to_s)
  end

  private

  # Instance helper methods
  def helper
    Object
      .new
      .extend(AppArchetype::Template::Helpers)
  end
end
