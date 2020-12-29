# frozen_string_literal: true

require_relative 'log'

class CProcess
  def self.execute(command, is_simulation)
    if is_simulation == true
      Log.display "execute : #{command}"
      [0, 0]
    else
      Log.info "Launch #{command}"
      result = `#{command}`
      status = $?
      Log.debug "result = #{result}"
      Log.debug "status = #{status} exit_status = #{status.exitstatus}"
      [result, status.exitstatus]
    end
  end

  def self.spawn(command, is_simulation)
    if is_simulation == true
      Log.display "launch : #{command}"
    else
      Log.info "Launch #{command}"
      pid = Process.spawn(command)
      Process.wait(pid)
    end
  end
end
