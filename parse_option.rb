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
          opt_state, in_error = parse_idle_arg(opt)
        when :init_get_folder, :register
          @args << opt
        when :help, :version
          break
        when :unknown_command
          break
        end
      end
    end
    
    case @command
    when :init
      if @args.count < 1
        puts 'missing argument for init command'
        in_error = true
      end
    when :register
      in_error = true if @args.count < 2
    end
    in_error
  end

  def parse_idle_arg(opt)
    in_error = false
    case opt
    when 'init'
      state = :init_get_folder
      @command = :init
    when 'help', '-h', '--help'
      state = :help
      @command = :help
    when 'version', '-v', '--version'
      state = :version
      @command = :version
    when 'register'
      @command = :register
      state = :register
    else
      state = :unknown_command
      in_error = true
    end
    [state, in_error]
  end
end
