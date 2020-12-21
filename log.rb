# frozen_string_literal: true

# Log class to filtrate some message
# according to required level
class Log

  def initialize
    @@verbose_level = 0
  end

  def self.error(msg)
    puts "error: #{msg}"
  end

  def self.warning(msg)
    puts "warning: #{msg}"
  end

  def self.display(msg)
    puts msg
  end

  def self.info(msg)
    puts "info: #{msg}" if @@verbose_level >= 1
  end

  def self.debug(msg)
    puts "dbg: #{msg}" if @@verbose_level >= 2
  end

  def self.verbose_level=(lvl)
    @@verbose_level = lvl
  end

  def self.verbose_level
    @@verbose_level
  end
end
