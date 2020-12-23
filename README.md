# ring

This tool can be used to manage several GIT repository.
Most of time, large projet uses multiple repository and
need to group them to produce a more large software.

This tool can help to manage whole GIT repository

here we are the list of commands of ring:
 - ring init <folder> : create a new repo organization
 - ring register <name> <url> <branch> <folder> :
    - insert a new repo inside group of depot at the specifed folder
        if folder is omitted, the repo will be retrieved at the current directory
        if branch is also omitted, it will be considered as default one
 - ring unregister <repo_name> : remove a repository
 - ring list (|repo|tag|action) <action name, with action>:
    - gives the list of repository managed (repo or no parameter)
    - with tag, gives the list of tag of each repository
    - with action, lists the action and command of each repositories
        a action name can be indicated to reduce list at this action
 - ring status : give the status of all repositories inclused in the configuration
 - ring clone : allow to clone all the repostories included in the configuration
 - ring destroy all : allow to remove all cloned repositories
 - ring create action <action_name> : create an action
 - ring insert action <action_name> <repo_name> <commands>
 - ring (execute|exec) <action_name> : execute the specified action for each repo
 - ring tag <tag_name> <msg>: create tag on all repositories and push it
 - ring push : execute push on all repositories
modifiers:
 -s : to simulate the command
 -v : add verbose information
 -vv : add more verbose information (debug)

