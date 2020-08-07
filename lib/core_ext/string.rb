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
