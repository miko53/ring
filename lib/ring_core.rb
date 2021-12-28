# frozen_string_literal: true

require_relative 'ring_config'
require_relative 'ring_scm'
require_relative 'process'
require_relative 'log'

class RingCore

  def self.get_scm(args)
    if args.count >= 3
      return nil unless args[args.count-2] == "with"
      case args[args.count-1]
      when 'git','hg'
        return args[args.count-1]
      else
        Log.display 'wrong scm, should be \'git\' or \'hg\''
        return nil
      end
    else
      return "git" 
    end
  end

  def self.perform_initialize(args, simulate)

    #p get_scm(args)
    scm = get_scm(args)
    return if scm.nil?

    r = CProcess.execute("mkdir #{args[0]}", simulate)
    r = CProcess.execute("cd #{args[0]} && #{scm} init", simulate) if r[1].zero?

    if simulate == true
      Log.display "create link file(#{LINK_FILENAME})"
      Log.display "create config file (#{args[0]}/#{CONFIG_FILENAME})"
      return true
    end

    if r[1].zero?
      config = RingConfig.new
      status = config.create(args[0], scm)
      Log.display 'initialize done successfully !' if status == true
    else
      Log.display 'initialize failed !'
    end
  end

  def self.perform_get(args, simulate)
    scm_obj = allocate_scm(args[0])
    return if scm_obj.nil?

    in_error = scm_obj.get(args[1], args[2], simulate)
    if simulate == true
      Log.display "create link file(#{LINK_FILENAME})"
      return true
    end

    if !in_error
      args[1].nil? ? default_folder = default_folder_name(args[1]) : default_folder = args[2]
      config = RingConfig.new
      status = config.create_link_file(default_folder)
      Log.display 'get correctly done' if status == true
    else
      Log.display 'get failed !'
    end
  end

  def self.perform_register(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    if repo_unique?(rconfig.config, args[0], args[3]) == true

      # set default value branch and folder when no precised
      args[3] = 'master' if args[3].nil? && args[1] == 'git'
      args[3] = 'default' if args[3].nil? && args[1] == 'hg'
      args[4] = default_folder_name(args[2]) if args[4].nil?
      rconfig.config['list_repo'] << { 'name' => args[0], 'scm' => args[1], 'url' => args[2], 'branch' => args[3], 'folder' => args[4] }
      rconfig.save unless simulate
      Log.display 'register correctly done!'
    else
      Log.display "repository #{args[0]} or located at #{args[4]} already exists, it can not be added a second one"
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

  def self.perform_status(_args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display("\nin #{repo['folder']}: (#{repo['scm']})")
      scm_obj = allocate_scm(repo['scm'])
      scm_obj.status(repo, simulate)
    end

    Log.display("\nin #{rconfig.config_folder}: (#{rconfig.scm})")
    r = CProcess.execute("cd #{rconfig.config_folder} && #{rconfig.scm} status", simulate)
    Log.display(r[0])
  end

  def self.perform_clone(_args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display("\nin #{repo['folder']}: (#{repo['scm']})")
      scm_obj = allocate_scm(repo['scm'])
      scm_obj.clone(repo, simulate)
    end
  end

  def self.perform_destroy(args, simulate)
    Log.warning('All the data stored in repository will be DELETED ! Please check before if all have been validated and pushed')
    Log.display('Confirm (yes/NO) ?')
    confirm = $stdin.gets.chomp
    if %w[yes y].include? confirm
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

  def self.perform_insert_action(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    action_selected = rconfig.config['actions'].select { |action| action['name'] == args[0] }.first
    if action_selected.nil?
      Log.error "action #{args[0]} not found"
    elsif rconfig.list_repo.select { |name| name == args[1] }.count.zero?
      Log.error("the repo #{args[1]} doesn't exist, command not added")
    else
      insert_repo_in_repo_action(action_selected, args)
      rconfig.save unless simulate
      Log.display 'done!'
    end
  end

  def self.perform_execute_action(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    action_to_perform = rconfig.config['actions'].select { |action_list| action_list['name'] == args[0] }.first
    if action_to_perform.nil?
      Log.error "action #{args[0]} not found"
    else
      action_to_perform['repo_action'].each do |action_repo|
        Log.display "in repo #{action_repo['repo']}:"
        repo = repo(rconfig, action_repo['repo'])
        CProcess.spawn("cd #{repo['folder']} && #{action_repo['command']}", simulate)
      end
      Log.display 'done!'
    end
  end
  
  def self.repo(rconfig, repo_name)
    rconfig.config['list_repo'].select { |repo| repo['name'] == repo_name}.first
  end

  def self.perform_list_action(args, _simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    list_action_repo = []
    if args[0].nil?
      list_action_repo = rconfig.config['actions']
    else
      list_action_repo = rconfig.config['actions'].select { |action| action['name'] == args[0] }
      Log.display "action #{args[0]} not found !" if list_action_repo.count.zero?
    end

    list_action_repo.each do |action_item|
      Log.display("action: #{action_item['name']}")

      action_item['repo_action'].each do |action_repo|
        Log.display "for #{action_repo['repo']}, command: #{action_repo['command']}"
      end
    end
  end

  def self.perform_tag(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display "create tag in folder: #{repo['folder']}"
      scm_obj = allocate_scm(repo['scm'])
      in_error = scm_obj.tag(repo, args[0], args[1], simulate)
      break if in_error
    end

    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display "push tag in folder: #{repo['folder']}"
      scm_obj = allocate_scm(repo['scm'])
      in_error = scm_obj.push(repo, true, simulate)
      break if in_error
    end
  end

  def self.perform_checkout_tag(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display "checkout tag #{args[0]} for #{repo['folder']}"
      scm_obj = allocate_scm(repo['scm'])
      in_error = scm_obj.checkout(repo, args[0], simulate)
      break if in_error
    end
  end

  def self.perform_list_tag(_args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display "tags of #{repo['name']}:"
      scm_obj = allocate_scm(repo['scm'])
      in_error = scm_obj.list_tag(repo, simulate)
      break if in_error
    end
  end

  def self.perform_push(_args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    return if in_error

    rconfig.config['list_repo'].each do |repo|
      Log.display "in folder: #{repo['folder']}"
      scm_obj = allocate_scm(repo['scm'])
      scm_obj.push(repo, false, simulate)
    end
  end

  # private method list

  def self.default_folder_name(url)
    last_name = url.split('/').last
    last_name.chomp('.git')
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

  def self.insert_repo_in_repo_action(action_selected, args)
    existing_action = action_selected['repo_action'].select { |repo_cmd| repo_cmd['repo'] == args[1] }.first
    if existing_action.nil?
      action_selected['repo_action'] << { 'repo' => args[1], 'command' => args[2] }
      Log.display("action inserted for repository #{args[1]}")
    else
      existing_action['command'] = args[2]
      Log.display("action updated for repository #{existing_action['repo']}")
    end
  end

  def self.allocate_scm(scm)
    scm_obj = nil
    case scm
    when 'git'
      scm_obj= RingScmGit.new
    when 'hg'
      scm_obj = RingScmHg.new
    else
      raise ImplementationError
    end
    scm_obj
  end

  private_class_method :default_folder_name, :repo_unique?
  private_class_method :do_really_perform_destroy, :action_already_exists?
  private_class_method :insert_repo_in_repo_action, :allocate_scm
end
