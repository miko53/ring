#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'parse_option'
require_relative 'ring_core'
require_relative 'log'

help_msg = '''here we are the list of command of ring:
 - ring init <folder> : create a new repo organization
 - ring register <name> <url> <branch> <folder> : insert a new repo inside group of depot at the specifed folder
                                                  if folder is omitted, the repo will be retrieved at the current directory
                                                  if branch is also omitted, it will be considered as default one
 - ring list : gives the list of repository managed 
modifiers:
 -s : to simulate the command
 -v : add verbose information
 -vv : for debug information
'''

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
  when :help
    Log.display version_msg
    Log.display help_msg
  when :version
    Log.display version_msg
  end
end
