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
    # Searches for manifests matching given name and returns it to caller.
    #
    # @example:
    #   manager = AppArchetype::Manager.new('/path/to/templates')
    #   fudge_manifest = manager.find('fudge')
    #
    # @param [String] name
    #
    # @return [Array]
    #
    def search_by_name(name)
      name_query = lambda do |template|
        template.name.include?(name)
      end

      filter(name_query)
    end

    ##
    # Finds a specific manifest by name and returns it to the caller.
    #
    # It is possible that a more than one manifest is found when searching
    # by name. If this happens while ignore_dupe is set to false, then a
    # Runtime error is raised. If ignore_dupe is set to false then the first
    # matching manifest is returned.
    #
    # @example:
    #   manager = AppArchetype::Manager.new('/path/to/templates')
    #   fudge_manifest = manager.find('fudge')
    #
    # @param [String] name
    # @param [Boolean] ignore_dupe
    #
    # @return [AppArchetype::Template::Manifest]
    #
    def find_by_name(name, ignore_dupe: false)
      name_query = lambda do |template|
        template.name == name
      end

      results = filter(name_query)

      if results.count > 1 && ignore_dupe == false
        raise 'more than one manifest matching the'\
        ' given name were found'
      end

      results.first
    end
  end
end
