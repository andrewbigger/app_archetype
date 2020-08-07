require 'app_archetype/template/helpers'

class String
  def snake_case
    helper.snake_case(self)
  end

  def dash_case
    helper.dash_case(self)
  end

  def randomize(size = 5)
    helper.randomize(self, size.to_s)
  end

  private

  def helper
    Object
      .new
      .extend(AppArchetype::Template::Helpers)
  end
end
