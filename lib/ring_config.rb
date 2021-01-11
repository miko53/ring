# frozen_string_literal: true

require 'yaml'
require_relative 'log'

CONFIG_FILENAME = 'ring_config'
LINK_FILENAME = '.ring_config'
CONFIG_VERSION = '0.0.1'

class RingConfig
  attr_accessor :config

  def initialize
    @link_config = {}
    @link_config['redirect_link'] = ''
    @config = {}
    @config['version'] = CONFIG_VERSION
    @config['list_repo'] = []
    @config['actions'] = []
  end

  def create(root_folder)
    file = File.open("#{root_folder}/" + CONFIG_FILENAME, 'w')
    file.write(@config.to_yaml)
    file.close

    create_link_file(root_folder)
  end

  def create_link_file(root_folder)
    @link_config['redirect_link'] = "#{root_folder}/" + CONFIG_FILENAME
    file = File.open(LINK_FILENAME, 'w')
    file.write(@link_config.to_yaml)
    file.close
    true
  end

  def read
    in_error = false
    if search_ring_link_file == true
      f = File.open(LINK_FILENAME, 'r')
      @link_config = YAML.safe_load(f)
      in_error = read_config_file
    else
      Log.error 'unable to find a ring config file until the root directory'
      in_error = true
    end
    in_error
  end

  def save
    @config_file.truncate(0)
    @config_file.rewind
    @config_file.write(@config.to_yaml)
  end

  def list_repo
    r = []
    @config['list_repo'].each do |repo|
      r << repo['name']
    end
    r
  end

  def config_folder
    File.dirname(@link_config['redirect_link'])
  end

  private

  def search_ring_link_file
    count = 0
    filename = LINK_FILENAME
    abs_path = File.realpath(Dir.getwd).split('/')
    found = false

    # search LINK_FILENAME until reach the root directory
    while !found && !abs_path.empty?
      path = abs_path.join('/') + "/#{filename}"
      if File.exist?(path)
        Log.warning "ring config file not found in current directory but in #{path}" if count >= 1
        Dir.chdir(File.dirname(path))
        found = true
      else
        abs_path.pop
      end
      count += 1
    end

    Log.debug "found = #{found} path = #{path}"
    found
  end

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
