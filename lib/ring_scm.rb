
require_relative 'log'
require_relative 'ring_config'

class RingScm

    def status(repo, simulate)
        raise Error
    end

    def clone(repo, simulate)
        raise Error
    end

end

class RingScmGit < RingScm

    def status(repo, simulate)
        r = CProcess.execute("cd #{repo['folder']} && git status", simulate)
        Log.display(r[0])        
    end

    def clone(repo, simulate)
        CProcess.execute("git clone --recursive #{repo['url']} --branch #{repo['branch']} #{repo['folder']}", simulate)
    end

end

class RingScmHg < RingScm

    def status(repo, simulate)
        r = CProcess.execute("cd #{repo['folder']} && hg status", simulate)
        Log.display(r[0])        
    end

    def clone(repo, simulate)
        CProcess.execute("hg clone #{repo['url']} --branch #{repo['branch']} #{repo['folder']}", simulate)
    end
    
end
