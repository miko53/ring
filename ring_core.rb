# frozen_string_literal: true

require 'byebug'
require_relative 'ring_config'
require_relative 'process'
require_relative 'log'

GIT_EXEC = 'git'

class RingCore
  def self.perform_initialize(args, simulate)
    r = CProcess.execute("mkdir #{args[0]}", simulate)
    r = CProcess.execute("cd #{args[0]} && #{GIT_EXEC} init", simulate) if r[1].zero?

    if simulate == true
      Log.display "create link file(#{LINK_FILENAME})"
      Log.display "create config file (#{args[0]}/#{CONFIG_FILENAME})"
      return true
    end

    if r[1].zero?
      config = RingConfig.new
      status = config.create(args[0])
      Log.display 'initialize done successfully !' if status == true
    else
      Log.display 'initialize failed !'
    end
  end

  def self.perform_register(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    if repo_unique?(rconfig.config, args[0], args[3]) == true

      # set default value branch and folder when no precised
      args[2] = 'master' if args[2].nil?
      args[3] = './' if args[3].nil?
      rconfig.config['list_repo'] << { 'name' => args[0], 'url' => args[1], 'branch' => args[2], 'folder' => args[3] }
      rconfig.save unless simulate
      Log.display 'register correctly done!'
    else
      Log.display "repository #{args[0]} or located at #{args[3]} already exists, it can not be added a second one"
    end
  end

  def self.perform_unregister(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].delete_if { |repo| repo['name'] == args[0] }
    Log.debug rconfig.config['list_repo']
    rconfig.save unless simulate
    Log.display 'unregister correctly done!'
  end

  def self.perform_list
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    Log.display 'list of registered repository:'
    rconfig.config['list_repo'].each do |repo|
      Log.display " - #{repo['name']} in #{repo['folder']} ==> #{repo['url']} (#{repo['branch']})"
    end
  end

  def self.perform_status(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display("\nin #{repo['folder']}:")
      r = CProcess.execute("cd #{repo['folder']} && #{GIT_EXEC} status", simulate)
      Log.display(r[0])
    end
  end

  def self.perform_clone(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display("\nin #{repo['folder']}:")
      CProcess.execute("#{GIT_EXEC} clone --recursive #{repo['url']} --branch #{repo['branch']} #{repo['folder']}", simulate)
    end
  end

  def self.perform_destroy(args, simulate)
    Log.warning('All the data stored in repository will be DELETED ! Please check before if all have been validated and pushed')
    Log.display('Confirm (yes/NO) ?')
    confirm = $stdin.gets.chomp
    if confirm == 'yes' || confirm == 'y'
      do_really_perform_destroy(args, simulate)
    else
      Log.display('canceled')
    end
  end

  def self.perform_create_action(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    if action_already_exists?(rconfig.config, args[0]) == true
      rconfig.config['actions'] << { 'name' => args[0], 'repo_action' => [] }
      rconfig.save unless simulate
      Log.display 'action correctly added!'
    else
      Log.display "action #{args[0]} already exists, it can not be added a second one"
    end
  end

  def self.repo_unique?(config, repo_name, repo_folder)
    # check if the name of the repository or the folder where clone is not already present in config
    config['list_repo'].select { |repo| ((repo['name'] == repo_name) || (repo['folder'] == repo_folder)) }.count.zero?
  end

  def self.do_really_perform_destroy(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      if args[0] == 'all' || (repo['name'] =~ Regexp.new(args[0]))
        Log.display("in #{repo['folder']}")
        CProcess.execute("rm -rf #{repo['folder']}", simulate)
      end
    end
  end

  def self.action_already_exists?(config, repo_name)
    # check if the name of the repository or the folder where clone is not already present in config
    config['actions'].select { |repo_action| (repo_action['name'] == repo_name) }.count.zero?
  end

  private_class_method :repo_unique?, :do_really_perform_destroy, :action_already_exists?
end
