module AppArchetype
  # Manager looks after a set of archetypes
  class Manager
    DEFAULT_QUERY = ->(_template) { return true }

    attr_reader :templates

    def initialize(template_dir)
      @template_dir = template_dir
      @templates = []
    end

    def load_templates
      Dir.glob(::File.join(@template_dir, '**', 'manifest.json')).each do |manifest|
        begin
          @templates << AppArchetype::Manifest.new_from_file(manifest)
        rescue StandardError
          puts "WARN: #{manifest} is invalid, skipping"
          next
        end
      end
    end

    def filter(query = DEFAULT_QUERY)
      @templates.select do |template|
        query.call(template)
      end
    end

    def find(search_term)
      name_query = lambda do |template|
        template.name.include?(search_term)
      end

      filter(name_query).first
    end
  end
end
