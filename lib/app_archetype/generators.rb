module AppArchetype
  # Generators create empty projects for the app_archetype gem
  module Generators
    # Default variables provided to new projects
    DEFAULT_VARS = {
      'example_string' => {
        'type' => 'string',
        'description' => 'This is an example string variable',
        'default' => 'default value'
      },
      'example_random_string' => {
        'type' => 'string',
        'description' => 'Example call to helper to generate 25 char string',
        'value' => '#random_string,25'
      }
    }.freeze

    # Function that creates a named, empty manifest for new templates
    TEMPLATE_MANIFEST = lambda do |name|
      {
        'name' => name,
        'version' => '1.0.0',
        'metadata' => {
          'app_archetype' => {
            'version' => AppArchetype::VERSION
          }
        },
        'variables' => DEFAULT_VARS
      }
    end

    # Function that creates a readme for a new blank template
    TEMPLATE_README = lambda do |name|
      <<~MD
        # #{name} Template

        ## Installation

        To generate:

        ```bash
          cd $HOME/Code
          mkdir my_#{name}
          cd $HOME/Code/my_#{name}

          archetype render #{name}
        ```
      MD
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
        template_path = File.join(path, name)
        manifest_path = File.join(path, 'manifest.json')
        readme_path = File.join(path, 'README.md')

        make_template_dir(template_path)
        render_manifest(manifest_path, name)
        render_readme(readme_path, name)
      end

      private

      def make_template_dir(path)
        FileUtils.mkdir_p(path)
      end

      def render_manifest(path, name)
        File.open(path, 'w') do |f|
          f.write(
            TEMPLATE_MANIFEST.call(name).to_json
          )
        end
      end

      def render_readme(path, name)
        File.open(path, 'w') do |f|
          f.write(
            TEMPLATE_README.call(name)
          )
        end
      end
    end
  end
end
