module AppArchetype
  # Generators create empty projects for the app_archetype gem
  module Generators
    # Default variables provided to new projects
    DEFAULT_VARS = {}.freeze

    # Function that creates a named, empty manifest for new templates
    TEMPLATE_MANIFEST = lambda do |name|
      {
        'name' => name,
        'version' => AppArchetype::VERSION,
        'variables' => DEFAULT_VARS
      }
    end

    class <<self
      ##
      # Render empty template renders a manifest and template folder at
      # the given path.
      #
      # The name param will be rendered into the template manifest at
      # runtime
      #
      # @param [String] name
      # @param [String] path
      #
      def render_empty_template(name, path)
        manifest_path = File.join(path, 'manifest.json')
        template_path = File.join(path, 'template')

        FileUtils.mkdir_p(template_path)
        File.open(manifest_path, 'w') do |f|
          f.write(
            TEMPLATE_MANIFEST.call(name).to_json
          )
        end
      end
    end
  end
end
