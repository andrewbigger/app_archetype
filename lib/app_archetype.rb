require 'core_ext/string'

require 'app_archetype/logger'
require 'app_archetype/template'

require 'app_archetype/template_manager'
require 'app_archetype/renderer'
require 'app_archetype/generators'

require 'app_archetype/cli/prompts'

require 'app_archetype/version'

# AppArchetype is the namespace for app_archetype
module AppArchetype
  def self.render(
    name,
    templates_dir,
    destination_path: Dir.pwd,
    overwrite: true,
    variables: []
  )
    manifest_file = File.join(templates_dir, name, 'manifest.json')

    manifest = AppArchetype::Template::Manifest.new_from_file(manifest_file)

    template = manifest.template
    template.load

    variables.each { |var| manifest.variables.add(var) }

    manifest.variables.all.each do |var|
      value = AppArchetype::CLI::Prompts.variable_prompt_for(var)
      var.set!(value)
    end

    plan = AppArchetype::Template::Plan.new(
      template,
      manifest.variables,
      destination_path: destination_path,
      overwrite: overwrite
    )

    plan.devise
    plan.execute
  end
end
