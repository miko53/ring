# frozen_string_literal: true

require 'yaml'
require 'byebug'
require_relative 'process'

CONFIG_FILENAME = 'ring_config'
LINK_FILENAME = '.ring_config'
CONFIG_VERSION = '1.0.0'

GIT_EXEC = 'git'

class RingCore
  
  def self.perform_initialize(args, simulate)
    r = CProcess.execute("mkdir #{args[0]}", simulate)
    if r[1].zero?
      r = CProcess.execute("cd #{args[0]} && #{GIT_EXEC} init", simulate)
    end

    if simulate == true
      puts "create link file(#{LINK_FILENAME})"
      puts "create config file (#{args[0]}/#{CONFIG_FILENAME})"
      return true
    end

    if r[1].zero?
      config = RingConfig.new
      status = config.create(args[0])
    end
    status
  end
  
  def self.perform_register(args, simulate)
    rconfig = RingConfig.new
    in_error = rconfig.read
    if !in_error
      if repo_unique?(rconfig.config, args[0]) == true
        args[2] = 'master' if args[2].nil?
        args[3] = './' if args[3].nil?
        rconfig.config['list_repo'] << { 'name' => args[0], 'url' => args[1], 'branch' => args[2], 'folder' => args[3] }
        rconfig.save unless simulate
        puts 'register correctly done!'
      else
        puts "repository #{args[0]} already exists, it can not be added a second one"
      end
    else
      puts 'unable to open ring config file'
    end
  end

  def self.repo_unique?(config, repo_name)
    config['list_repo'].select { |repo| repo['name'] == repo_name }.count.zero?
  end

  private_class_method :repo_unique?
end

class RingConfig

  attr_accessor :config

  def initialize
    @link_config = {}
    @link_config['redirect_link'] = ''
    @config = {}
    @config['version'] = CONFIG_VERSION
    @config['list_repo'] = []
  end

  def create(root_folder)
    file = File.open("#{root_folder}/" + CONFIG_FILENAME, 'w')
    file.write(@config.to_yaml)
    file.close

    @link_config['redirect_link'] = "#{root_folder}/" + CONFIG_FILENAME
    file = File.open(LINK_FILENAME, 'w')
    file.write(@link_config.to_yaml)
    file.close
    true
  end

  def read
    in_error = false
    if File.exist?(LINK_FILENAME)
      f = File.open(LINK_FILENAME, 'r')
      @link_config = YAML.safe_load(f)
      in_error = read_config_file
    else
      puts 'no ring configuration defined here...'
      in_error = true
    end
    in_error
  end

  def save
    @config_file.rewind
    @config_file.write(@config.to_yaml)
  end

  private

  def read_config_file
    in_error = false
    if File.exist?(@link_config['redirect_link'])
      @config_file = File.open(@link_config['redirect_link'], 'r+')
      @config = YAML.safe_load(@config_file)
    else
      in_error = true
    end
    in_error
  end
end
