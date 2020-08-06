module AppArchetype
  # CLI Logging methods
  module Logger
    ##
    # Creates logger for printing messages
    #
    # Sets the formatter to output only the provided message to the
    # specified IO
    #
    # @param [IO] out - default: STDOUT
    #
    # @return [::Logger]
    #
    def logger(out = STDOUT)
      @logger ||= ::Logger.new(out)
      @logger.formatter = proc do |_sev, _time, _prog, msg|
        "#{msg}\n"
      end

      @logger
    end

    ##
    # Prints TTY table to STDOUT
    #
    # @param [TTY::Table] table
    #
    # @return [::Logger]
    def print_table(table)
      logger.info(
        table.render(:ascii)
      )
    end

    ##
    # Prints command line message to STDOUT
    #
    # For use when printing info messages for a user to STDOUT
    #
    # @param [String] message - message to be printed
    #
    def print_message(message)
      logger.info(message)
    end

    ##
    # Prints warning to STDOUT
    #
    # For use when printing warn messages to STDOUT
    #
    # @param [String] message - message to be printed
    #
    def print_warning(message)
      logger.warn(message)
    end

    ##
    # Prints error to STDERR
    #
    # For indicating fatal message to user
    #
    # @param [String] message - message to be printed
    #
    def print_error(message)
      logger(STDERR).error(message)
    end

    ##
    # Prints a message and then exits with given status code
    #
    # This will terminate the program with the given status code
    #
    # @param [String] message - message to be printed
    # @param [Integer] exit_code - exit status (default: 1)
    #
    def print_message_and_exit(message, exit_code = 1)
      print_message(message)
      exit(exit_code)
    end
  end
end
