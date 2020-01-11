require 'fileutils'
require 'erb'

module AppArchetype
  # Renderer renders a plan
  class Renderer
    def initialize(plan, variables, overwrite = false)
      @plan = plan
      @overwrite = overwrite
      @variables = variables
    end

    def render
      write_dir(@plan.destination_path)

      @plan.files.each do |file|
        if file.source_directory?
          write_dir(file)
        elsif file.source_template?
          render_file(file)
        elsif file.source_file?
          copy_file(file)
        end
      end
    end

    def write_dir(file)
      FileUtils.mkdir_p(file.path)
    end

    def render_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      input = ::File.read(file.source_file_path)
      out = ERB.new(input).result(@variables.instance_eval { binding })

      ::File.open(file.path.gsub('.erb', ''), 'w+') { |f| f.write(out) }
    end

    def copy_file(file)
      raise 'cannot overwrite file' if file.exist? && !@overwrite

      FileUtils.cp(file.source_file_path, file.path)
    end
  end
end