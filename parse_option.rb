# frozen_string_literal: true

class ParseOption
  attr_reader :command, :args, :simulate

  def initialize
    @command = :no_command
    @simulate = false
    @args = []
  end

  def parse_option(argv)
    in_error = false
    opt_state = :no_command

    argv.each do |opt|
      if opt == '-s'
        @simulate = true
      else
        case opt_state
        when :no_command
          opt_state = parse_idle_arg(opt)
        when :init_get_folder
          @args << opt
        when :help, :version
          break
        end
      end
    end
    in_error
  end

  def parse_idle_arg(opt)
    case opt
    when 'init'
      state = :init_get_folder
      @command = :init
    when 'help'
      state = :help
      @command = :help
    when 'version', '-v', '--version'
      state = :version
      @command = :version
    end
    state
  end
end
