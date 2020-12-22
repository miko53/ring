# frozen_string_literal: true

class ParseOptionState
  IDLE = 0
  PARSE_COMMAND = 1
  PARSE_CREATE_COMMAND = 2
  GET_NEXT_ARGS = 3
  END_PARSE = 4
  PARSE_INSERT_COMMAND = 5
end

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
    opt_state = ParseOptionState::IDLE
    argv.each do |opt|
      next if check_modifier(opt)

      case opt_state
      when ParseOptionState::IDLE
        opt_state, in_error = parse_idle_arg(opt)
      when ParseOptionState::GET_NEXT_ARGS
        @args << opt
      when ParseOptionState::END_PARSE
        break
      when ParseOptionState::PARSE_CREATE_COMMAND
        opt_state, in_error = parse_create_command(opt)
      when ParseOptionState::PARSE_INSERT_COMMAND
        opt_state, in_error = parse_insert_command(opt)
      else
        in_error = true
        break
      end
    end

    in_error = check_nb_argument unless in_error == true
    in_error
  end

private
  def check_modifier(option)
    is_modifier = true
    case option
    when '-s'
      @simulate = true
    when '-v'
      @verbose = 1
    when '-vv'
      @verbose = 2
    else
      is_modifier = false
    end
    is_modifier
  end

  def check_nb_argument
    in_error = false
    case @command
    when :init
      if @args.count < 1
        puts 'missing argument for init command'
        in_error = true
      end
    when :register
      in_error = true if @args.count < 2
    when :unregister
      in_error = true if @args.count < 1
    when :help, :version, :list, :status, :clone
      # no special do
    when :destroy
      if @args.count < 1
        puts 'precise if all repository are concerned [all] or give a repo'
        in_error = true
      end
    when :create_action
      if @args.count < 1
        puts 'name action is not specified, please add it'
        in_error = true
      end
    when :insert_action
      if @args.count < 3
        puts 'missing argument'
        in_error = true
      end
    else
      in_error = true
    end
    in_error
  end

  def parse_idle_arg(option)
    in_error = false
    case option
    when 'init'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :init
    when 'help', '-h', '--help'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :help
    when 'version', '-v', '--version'
      state = ParseOptionState::END_PARSE
      @command = :version
    when 'register'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :register
    when 'unregister'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :unregister
    when 'list'
      state = ParseOptionState::END_PARSE
      @command = :list
    when 'status'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :status
    when 'clone'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :clone
    when 'destroy'
      state = ParseOptionState::GET_NEXT_ARGS
      @command = :destroy
    when 'create'
      state = ParseOptionState::PARSE_CREATE_COMMAND
    when 'insert'
      state = ParseOptionState::PARSE_INSERT_COMMAND
    else
      state = ParseOptionState::IDLE
      in_error = true
    end
    [state, in_error]
  end

  def parse_create_command(option)
    in_error = false
    case option
    when 'action'
      @command = :create_action
      state = ParseOptionState::GET_NEXT_ARGS
    else
      state = ParseOptionState::PARSE_CREATE_COMMAND
      in_error = true
    end
    [state, in_error]
  end

  def parse_insert_command(option)
    in_error = false
    case option
    when 'action'
      @command = :insert_action
      state = ParseOptionState::GET_NEXT_ARGS
    else
      state = ParseOptionState::PARSE_INSERT_COMMAND
      in_error = true
    end
    [state, in_error]
  end
end
