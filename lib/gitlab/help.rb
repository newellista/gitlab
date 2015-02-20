require 'gitlab'
require 'gitlab/cli_helpers'

module Gitlab::Help
  extend Gitlab::CLI::Helpers

  class << self

    # Returns the (modified) help from the 'ri' command or returns an error.
    #
    # @return [String]
    def get_help(cmd)
      cmd_namespace = namespace cmd

      if cmd_namespace
        ri_output = `#{ri_cmd} -T #{cmd_namespace} 2>&1`.chomp

        if $? == 0
          change_help_output! cmd, ri_output
          ri_output
        else
          "Ri docs not found for #{cmd}, please install the docs to use 'help'."
        end
      else
        "Unknown command: #{cmd}."
      end
    end

    # Finds the location of 'ri' on a system.
    #
    # @return [String]
    def ri_cmd
      @ri_cmd if @ri_cmd

      which_ri = `which ri`.chomp
      if which_ri.empty?
        raise "'ri' tool not found in your PATH, please install it to use the help."
      end

      @ri_cmd = which_ri
    end

    # Returns full namespace of a command (e.g. Gitlab::Client::Branches.cmd)
    def namespace(cmd)
      method_owners.select { |method| method[:name] === cmd }.
                    map    { |method| method[:owner] + '.' + method[:name] }.
                    shift
    end

    # Massage output from 'ri'.
    def change_help_output!(cmd, output_str)
      output_str.gsub!(/#{cmd}\((.*?)\)/m, cmd+' \1')
      output_str.gsub!(/Gitlab\./, 'gitlab> ')
      output_str.gsub!(/Gitlab\..+$/, '')
      output_str.gsub!(/\,[\s]*/, ' ')
    end

  end # class << self
end

