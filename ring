#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'parse_option'
require_relative 'ring_core'

help_msg = '''here we are the list of command of ring:
 - ring init <folder> : create a new repo organization
 - ring register <name> <url> <branch> <folder> : insert a new repo inside group of depot at the specifed folder
                                                  if folder is omitted, the repo will be retrieved at the current directory
                                                  if branch is also omitted, it will be considered as default one
'''

version_msg = 'ring version 0.1 ()'

parser = ParseOption.new
in_error = parser.parse_option(ARGV)

# open_config_file

p "in_error = #{in_error}"
p "simulation #{parser.simulate}"
p "command = #{parser.command}"
p "argument = #{parser.args}"

if in_error
  puts 'wrong command, try help'
else
  case parser.command
  when :init
    RingCore.perform_initialize(parser.args, parser.simulate)
  when :register
    RingCore.perform_register(parser.args, parser.simulate)
  when :help
    puts version_msg
    puts help_msg
  when :version
    puts version_msg
  end
end
