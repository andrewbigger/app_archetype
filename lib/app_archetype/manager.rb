module AppArchetype
  # Manager looks after a set of archetypes
  class Manager
    ##
    # Default filter is a lambda that returns true for all manifests
    #
    DEFAULT_QUERY = ->(_manifest) { return true }

    attr_reader :manifests

    ##
    # Creates a manager
    #
    # @param [String] template_dir
    #
    def initialize(template_dir)
      @template_dir = template_dir
      @manifests = []
    end

    ##
    # Loads and parses each manifest within the template directory into
    # memory. Any invalid manifests are ignored and a message is printed
    # to STDOUT indicating which manifest is not valid.
    #
    def load
      Dir.glob(
        File.join(@template_dir, '**', 'manifest.json*')
      ).each do |manifest|
        begin
          @manifests << AppArchetype::Template::Manifest.new_from_file(manifest)
        rescue StandardError
          puts "WARN: #{manifest} is invalid, skipping"
          next
        end
      end
    end

    ##
    # Filter executes a query function in a select call against each manifest
    # in the manager's collection.
    #
    # The given query function should be something that will evaluate to true
    # when the manifest matches - this will hence filter the manifest set to
    # the filtered set.
    #
    # @example
    #   manager = AppArchetype::Manager.new('/path/to/templates')
    #   query = -> (manifest) { manifest.name = "fudge" }
    #
    #   fudge_templates = manager.filter(query)
    #
    # @param [Lambda] query
    #
    # @return [Array]
    def filter(query = DEFAULT_QUERY)
      @manifests.select do |template|
        query.call(template)
      end
    end

    ##
    # Finds a manifest by name and returns it to caller.
    #
    # When there are more than one results, this will select and return the
    # first result. When nothing matches the search term this will return nil.
    #
    # @example:
    #   manager = AppArchetype::Manager.new('/path/to/templates')
    #   fudge_manifest = manager.find('fudge')
    #
    # @param [String] search_term
    #
    # @return [AppArchetype::Manifest]
    #
    def find(search_term)
      name_query = lambda do |template|
        template.name.include?(search_term)
      end

      filter(name_query).first
    end
  end
end
