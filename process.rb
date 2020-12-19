# frozen_string_literal: true

class CProcess
  def self.execute(command, isSimulate)
    if isSimulate == true
      puts("execute : #{command}")
      [0, 0]
    else
      result = `#{command}`
      status = $?
      p "result = #{result}"
      p "status = #{status} exit_status = #{status.exitstatus}"
      [result, status.exitstatus]
    end
  end
end
