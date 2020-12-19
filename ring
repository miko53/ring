#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'yaml'
# require 'getoptlong'
# require 'optparse'
# require 'byebug'
require_relative 'parse_option'
require_relative 'ring_core'

def open_config_file
  f = File.open(CONFIG_FILENAME, 'r')
rescue Errno::ENOENT
  p 'not file exists'
else
  p 'ok file exists'
end

help_msg = '''here we are the list of command of ring:
 - ring init <folder> : create a new repo organization
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
  puts "wrong command, try help"
else
  case parser.command
  when :init
    RingCore.perform_initialize(parser.args, parser.simulate)
  when :help
    puts version_msg
    puts help_msg
  when :version
    puts version_msg
  end
end
