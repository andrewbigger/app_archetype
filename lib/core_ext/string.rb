require 'app_archetype/template/helpers'

# Archetype extensions for String
class String
  ##
  # Converts string to snake case
  #
  # @return [String]
  #
  def snake_case(str = nil)
    str ||= self
    helper.snake_case(str)
  end

  ##
  # Converts string to dash case
  #
  # @return [String]
  #
  def dash_case(str = nil)
    str ||= self
    helper.dash_case(str)
  end

  ##
  # Converts a string to camel case
  #
  # @return [String]
  #
  def camel_case(str = nil)
    str ||= self
    helper.camel_case(str)
  end

  ##
  # Attempts to pluralize a word
  #
  # @return [String]
  #
  def pluralize(str = nil)
    str ||= self
    helper.pluralize(str)
  end

  ##
  # Attempts to singluarize a word
  #
  # @return [String]
  #
  def singularize(str = nil)
    str ||= self
    helper.singularize(str)
  end

  ##
  # Adds a random string of specified length at the end
  #
  # @return [String]
  #
  def randomize(size = 5, str = nil)
    str ||= self
    helper.randomize(str, size.to_s)
  end

  private

  # Instance helper methods
  def helper
    Object
      .new
      .extend(AppArchetype::Template::Helpers)
  end
end
