require 'hashie'

ARCHETYPE_CLI_COMMANDS = File.join(__dir__, 'commands', '*.rb')

Dir[ARCHETYPE_CLI_COMMANDS].sort.each do |file|
  require file
end

module AppArchetype
  # Module for CLI command classes
  module Commands
  end
end
