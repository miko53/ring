# frozen_string_literal: true

require_relative 'log'
require_relative 'ring_config'

# class groups all GIT commands
class RingScmGit
  def status(repo, simulate)
    r = CProcess.execute("cd #{repo['folder']} && git status", simulate)
    Log.display(r[0])
  end

  def get(url, folder, simulate)
    r = CProcess.execute("git clone --recursive #{url} #{folder}", simulate)
    if r[1].zero?
      false
    else
      true
    end
  end

  def clone(repo, simulate)
    CProcess.execute("git clone --recursive #{repo['url']} --branch #{repo['branch']} #{repo['folder']}", simulate)
  end

  def tag(repo, tag_name, msg, simulate)
    in_error = false
    r = CProcess.execute("cd #{repo['folder']} && git tag -a #{tag_name} -m \"#{msg}\"", simulate)
    unless r[1].zero?
      Log.error 'unable to create tag, aborted'
      in_error = true
    end
    in_error
  end

  def push(repo, push_tag, simulate)
    in_error = false
    if push_tag
      r = CProcess.execute("cd #{repo['folder']} && git push --follow-tag", simulate)
      unless r[1].zero?
        Log.error "unable to push tag for #{repo['folder']}"
        in_error = true
      end
    else
      r = CProcess.execute("cd #{repo['folder']} && git push origin #{repo['branch']}", simulate)
      unless r[1].zero?
        Log.error 'unable to perform push, aborted'
        in_error = true
      end
    end
    in_error
  end

  def checkout(repo, tag, simulate)
    in_error = false
    r = CProcess.execute("cd #{repo['folder']} && git checkout #{tag} && git submodule update", simulate)
    unless r[1].zero?
      Log.error 'unable to checkout tag'
      in_error = true
    end
    in_error
  end

  def list_tag(repo, simulate)
    r = CProcess.execute("cd #{repo['folder']} && git tag", simulate)
    Log.error 'unable to retrieve tag list, aborted' unless r[1].zero?
    Log.display r[0].to_s if r[1].zero?
  end
end

# class groups all mercurial commands
class RingScmHg
  def status(repo, simulate)
    r = CProcess.execute("cd #{repo['folder']} && hg branch", simulate)
    Log.display("In branch #{r[0]}") if r[1].zero?
    r = CProcess.execute("cd #{repo['folder']} && hg status", simulate)
    Log.display(r[0].to_s) unless simulate == true || (r[0].empty? && r[1].zero?)
    Log.display('Your branch is up-to-date') if simulate == false && r[0].empty? && r[1].zero?
    r = CProcess.execute("cd #{repo['folder']} && hg outgoing", simulate)
    Log.display(r[0])
  end

  def get(url, folder, simulate)
    r = CProcess.execute("hg clone #{url} #{folder}", simulate)
    if r[1].zero?
      false
    else
      true
    end
  end

  def clone(repo, simulate)
    r = CProcess.execute("hg clone #{repo['url']} --branch #{repo['branch']} #{repo['folder']}", simulate)
    Log.display("Clone in '#{repo['folder']}'") if r[1].zero?
    Log.display('Done') if r[1].zero?
  end

  def tag(repo, tag_name, msg, simulate)
    in_error = false
    r = CProcess.execute("cd #{repo['folder']} && hg tag -m \"#{msg}\" #{tag_name}", simulate)
    unless r[1].zero?
      Log.error 'unable to create tag, aborted'
      in_error = true
    end
    in_error
  end

  def push(repo, _push_tag, simulate)
    in_error = false
    r = CProcess.execute("cd #{repo['folder']} && hg push", simulate)
    unless r[1].zero?
      Log.error 'unable to push, aborted'
      in_error = true
    end
    in_error
  end

  def checkout(repo, tag, simulate)
    in_error = false
    r = CProcess.execute("cd #{repo['folder']} && hg checkout #{tag}", simulate)
    unless r[1].zero?
      Log.error 'unable to checkout tag'
      in_error = true
    end
    in_error
  end

  def list_tag(repo, simulate)
    r = CProcess.execute("cd #{repo['folder']} && hg tags", simulate)
    Log.error 'unable to retrieve tag list, aborted' unless r[1].zero?
    Log.display r[0].to_s if r[1].zero?
  end
end
