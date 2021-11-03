require 'core_ext/string'

require 'app_archetype/logger'
require 'app_archetype/template'

require 'app_archetype/template_manager'
require 'app_archetype/renderer'
require 'app_archetype/generators'

require 'app_archetype/version'
require_relative './app_archetype/commands'

# AppArchetype is the namespace for app_archetype
module AppArchetype
  ##
  # Self contained template render method
  #
  # Takes collection directory and template name to
  # load a new manager and find the desired template
  #
  # Then executes a render template command with the
  # found template
  #
  # Returns the manifest rendered. Target can optionally
  # be set to overwrite
  #
  # This method is to be used for self contained rendering#
  # scripts.
  #
  # @param [String] collection_dir
  # @param [String] template_name
  # @param [String] destination_path
  # @param [Boolean] overwrite
  #
  # @return [AppArchetype::Template::Manifest]
  #
  def self.render_template(
    collection_dir: ENV.fetch('ARCHETYPE_TEMPLATE_DIR'),
    template_name: '',
    destination_path: '',
    overwrite: false
  )
    manager = AppArchetype::TemplateManager.new(collection_dir)
    manager.load

    manifest = manager.find_by_name(template_name)

    template = manifest.template
    template.load

    options = Hashie::Mash.new(
      name: template_name,
      overwrite: overwrite
    )

    command = AppArchetype::Commands::RenderTemplate.new(
      manager, destination_path, options
    )

    command.run

    manifest
  end
end
