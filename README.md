# ring

This tool can be used to manage several repository (git or mercurial).
Most of time, large projet uses multiple repository and
need to group them to produce a more large software.

This tool can help to manage whole git/mercurial (or mixed) repository.

## How it work ? initialisation

ring uses a special repository to store information about another one.
It is declared with the command:
 - `ring init <folder> with <scm>`
with this command, ring creates a repository with the specified scm (`git` or `hg`) in `<folder>` and stores inside
a file `ring_config` which stores all necessary information on repository.
Moreover a file `.ring_config` is created when the command is launched and do a link
with the `<folder>` directory

Then you can use the command `register` to insert repositories to include

When the configuration has already been created, the following command permit to retreive
it:
 - `ring get <scm> <url>`
 with `url` the repository where stores them.
 with `scm` the configuration tool used to store them
This command does a clone of repository given by url in the current working directory.
These repository must contains the `ring_config` file. In addition, the command creates the
`.ring_config` and link to the given repository

## Installation

build the gem
 - `gem build ring.gemspec`

and install it
 - `sudo gem install ring-0.0.2.gem`

otherwise if you don't want it, you can source the bin directory to try. `export PATH=<bin folder>:$PATH`

## Example

Example of retrievable (repositories in folder, no action specified:

```
miko53@F2003-GA:~/programmation/temp/test_get  $ ll
total 0
miko53@F2003-GA:~/programmation/temp/test_get  $ ring get git ../test_ring/script/
Clonage dans 'script'...
fait.
get correctly done
miko53@F2003-GA:~/programmation/temp/test_get  $ ring clone

in repo/repo_3:
Clonage dans 'repo/repo_3'...
fait.

in repo/repo_2:
Clonage dans 'repo/repo_2'...
fait.

in repo_4:
Clonage dans 'repo_4'...
fait.
miko53@F2003-GA:~/programmation/temp/test_get  $ tree
.
├── repo
│   ├── repo_2
│   │   └── REPO2.md
│   └── repo_3
│       ├── main.c
│       └── REPO_3.md
├── repo_4
│   └── REPO_4.md
└── script
    └── ring_config

5 directories, 5 files
miko53@F2003-GA:~/programmation/temp/test_get  $ cat script/ring_config
---
version: 0.0.2
list_repo:
- name: repo_3
  scm: git
  url: "/home/miko53/programmation/temp/test_ring/repo_store/repo_3"
  branch: master
  folder: repo/repo_3
- name: repo_2
  url: "/home/miko53/programmation/temp/test_ring/repo_store/repo_2"
  scm: git
  branch: master
  folder: repo/repo_2
- name: repo_4
  url: "/home/miko53/programmation/temp/test_ring/repo_store/repo_4.git"
  scm: git
  branch: master
  folder: repo_4
actions: []
scm: git
```

## Main command

### Command register

`ring register <scm> <repository name> <repository url> <checkout branch> <folder where clone it>`

This command declares a new repository (by including it into `ring_config` file)/
it allows you to automatically clone it in the specified directory and checkout the right branch
(with the `command ring clone`).
The folder is given in reference to the `.ring_config` file.

### Command list

`ring list`

Returns the list of registred repositories

### Command status

`ring status`

This command executes a `git status` or `hg status` on each declared repository and displays the result.

### Command clone

`ring clone`
With this command you can retrieve all the registered repositories listed in the configuration file.
By executing the `git clone` or `hg clone` command.

It is probably the second command after the `ring get` one

## Command to manage actions

the action commands can be used to group into one command, several commands to be executed on repository.
For example, an action 'make' can be created to launch a `make <app1>` on one repository but call a `make <app2>`
on a second one.

### Command create action

An action is inserted by applying the command `ring create action <action_name>`. This call just register the command into the configuration file

### Command insert action

By this command, a action is associated to an executable to be applied. The command is the following:
 - `ring insert action <action_name> <repo_name> <command>`

Where the <action_name> is the action previously registered, the <repo_name> the name of the command where the command must be executed

### Command execute

The most important command is the execute, it permits to launch the previously registered actions on each repository. The command is the following:
- `ring execute action <action_name>`

## Miscellaneous commands

Another command are provided for example :
 - `unregister` for remove a repository from the list
 - `list` list can also given the list of tag on each repositories or the list of configurated action

### Command destroy

This command is a little bit dangerous, with it, you can remove all previously cloned repositories.
- `ring destroy all`

### Command tag

This command is used to create a tag and propagate it on all registered repositories.
The tag is created on the head of each repositories.

### Command checkout

This command can be used to checkout whole repositories on a specified tag (or branch).
It updates also sub-module.

### Command push

In a similar way that for tag, this command push all commit of declared branchs.

## List of commands

here we are the list of commands of ring:
 - ring get <scm> <url> : retrieve ring configuration
 - ring init <folder> (with <scm>): create a new repo organization optional with precize scm (git or hg)
 - ring register <name> <scm> <url> <branch> <folder> :
    - insert a new repo inside a group of repo at the specifed folder
        <scm> indicate type of repository ('hg' or 'git' supported)
        if <folder> is omitted, the repo will be retrieved at the current directory
        if <branch> is also omitted, it will be considered as default one
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
 - ring checkout <tag_name>|<branch_name : retrieve all repositories on this tag or branch
 - ring push : execute push on all repositories

 modifiers:

 - `-s` : to simulate the command (usefull to know which commands will be launched)
 - `-v` : add verbose information
 - `-vv` : add more verbose information (debug)

