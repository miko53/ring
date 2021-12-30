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

  def self.display(msg, color = :default)
    colorize(color) unless color == :default
    puts msg
    uncolorize(color) unless color == :default
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

  def self.colorize(color)
    case color
    when :red
      puts "\e[31m"
    when :green
      puts "\e[32m"
    else
    end
  end

  def self.uncolorize(color)
    puts "\e[0m"
  end

  private_class_method :colorize, :uncolorize

end
