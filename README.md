# ring

This tool can be used to manage several GIT repository.
Most of time, large projet uses multiple repository and
need to group them to produce a more large software.

This tool can help to manage whole GIT repository

## how it work ? initialisation

ring uses a special repository to store information about another one.
It is declared with the command:
 - `ring init <folder>`
with this command, ring creates a GIT repository in `<folder>` and stores inside
a file `ring_config` which stores all necessary information on repository.
Moreover a file `.ring_config` is created when the command is launched and do a link
with the `<folder>` directory

Then you can use the command `register` to insert repositories to include


## main commands

### command register

`ring register <repository name> <repository url> <checkout branch> <folder where clone it>`

This command declares a new repository (by including it into `ring_config` file)/
it allows you to automatically clone it in the specified directory and checkout the right branch
(with the `command ring clone`)

### command list

`ring list`

Returns the list of registred repositories

### command status

`ring status`

This command executes a `git status` on each declared repository and displays the result

## list of commands

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
