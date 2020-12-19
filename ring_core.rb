# frozen_string_literal: true

require 'yaml'
require_relative 'process'

CONFIG_FILENAME = 'ring_config'
GIT_EXEC = 'git'

class RingCore
  
  def self.perform_initialize(args, simulate)
    
    r = CProcess.execute("mkdir #{args[0]}", simulate)
    if (r[1].zero?)
      r = CProcess.execute("cd #{args[0]} && #{GIT_EXEC} init", simulate)
    end

    if (simulate == true)
      puts "create config file"
      return
    end
    
    if (r[1].zero?)
      s = create_config_file(args[0]) 
    end

    if (s == true)
      s = create_link_config_file(args[0])
    end
    
  end

  def self.create_config_file(root_folder)
    file = File.open("#{root_folder}/#{CONFIG_FILENAME}", 'w')
    root_config = {}
    file.write(root_config.to_yaml)
    file.close
    true
  end

  def self.create_link_config_file(root_folder)
    file = File.open(".#{CONFIG_FILENAME}", 'w')
    redirect = { redirect_link: "#{root_folder}/#{CONFIG_FILENAME}" }
    file.write(redirect.to_yaml)
    file.close
    true
  end
end
