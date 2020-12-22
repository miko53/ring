#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'parse_option'
require_relative 'ring_core'
require_relative 'log'

help_msg = <<-HELP_MSG
here we are the list of command of ring:
 - ring init <folder> : create a new repo organization
 - ring register <name> <url> <branch> <folder> :
    - insert a new repo inside group of depot at the specifed folder
        if folder is omitted, the repo will be retrieved at the current directory
        if branch is also omitted, it will be considered as default one
 - ring unregister <repo_name> : remove a repository
 - ring list : gives the list of repository managed
 - ring status : give the status of all repositories inclused in the configuration
 - ring clone : allow to clone all the repostories included in the configuration
 - ring destroy all : allow to remove all cloned repositories
 - ring create action <action_name> : create an action
 - ring insert action <action_name> <repo_name> <commands>
modifiers:
 -s : to simulate the command
 -v : add verbose information
 -vv : add more verbose information (debug)
HELP_MSG

version_msg = 'ring version 0.1 ()'

parser = ParseOption.new
in_error = parser.parse_option(ARGV)

Log.verbose_level = parser.verbose

Log.debug "in_error = #{in_error}"
Log.debug "simulation #{parser.simulate}"
Log.debug "command = #{parser.command}"
Log.debug "argument = #{parser.args}"

if in_error
  Log.display 'wrong command, try help'
else
  case parser.command
  when :init
    RingCore.perform_initialize(parser.args, parser.simulate)
  when :register
    RingCore.perform_register(parser.args, parser.simulate)
  when :unregister
    RingCore.perform_unregister(parser.args, parser.simulate)
  when :list
    RingCore.perform_list
  when :help
    Log.display version_msg
    Log.display help_msg
  when :version
    Log.display version_msg
  when :status
    RingCore.perform_status(parser.args, parser.simulate)
  when :clone
    RingCore.perform_clone(parser.args, parser.simulate)
  when :destroy
    RingCore.perform_destroy(parser.args, parser.simulate)
  when :create_action
    RingCore.perform_create_action(parser.args, parser.simulate)
  end
end
