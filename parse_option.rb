# frozen_string_literal: true

class ParseOption
  attr_reader :command, :args, :simulate, :verbose

  def initialize
    @command = :no_command
    @simulate = false
    @verbose = 0
    @args = []
  end

  def parse_option(argv)
    in_error = false
    opt_state = :no_command

    argv.each do |opt|
      @simulate = true if opt == '-s'
      @verbose = 1 if opt == '-v'
      @verbose = 2 if opt == '-vv'
      case opt_state
      when :no_command
        opt_state, in_error = parse_idle_arg(opt)
      when :init_get_folder, :register, :status_get_repo, :clone_get_repo, :destroy_get_repo
        @args << opt
      when :help, :version
        break
      when :list, :unknown_command
        break
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
    when :help, :version, :list, :status, :clone
      # no special do
    when :destroy
      if @args.count < 1
        puts 'precise if all repository are concerned [all] or give a repo'
        in_error = true
      end
    else
      in_error = true
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
    when 'list'
      @command = :list
      state = :list
    when 'status'
      @command = :status
      state = :status_get_repo
    when 'clone'
      @command = :clone
      state = :clone_get_repo
    when 'destroy'
      @command = :destroy
      state = :destroy_get_repo
    else
      state = :unknown_command
      in_error = true
    end
    [state, in_error]
  end
end
