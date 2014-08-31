## Changelog

### 3.10.3

- Fix for branch names being shortened unnecessarily.

### 3.10.2

- Fix 'Git Log' for windows users

### 3.10.1

- Git pull lists remotes if there are multiple and remote branches

### 3.9.0

- From the Git Status list, you can go to the modified file or open its diff file
### 3.8.0

- Adding commands for Git stash

### 3.7.0

- new `Reset HEAD` allows unstaging all changes

### 3.6.2

- Patch to resolve when atom project is a subfolder of a repository

### 3.6.1

- Can change commentchar in Git configs and Git-plus will use it in commit messages

### 3.6.0
- Can now push tags to remote

### 3.5.0

- The more common commands are now accessible through keybindings  

    * Add
    * Add all and commit
    * Add and commit
    * Commit
    * Diff [all]
    * Log
    * Status
    * Pull
    * Push

### 3.4.0

- Debut of submodule support by the plugin.

- Submodule commands should be run while a submodule file is the current file

### 3.3.2

- Fix for not being able to commit on windows

### 3.3.0

- New setting to specify where to open the pane for commits and such...

### 3.1.0

- Git-palette doesn't show 'Git-plus:' prefix in front of commands.

- Add `diff`, `diff all`, `log`, to startup commands in regular command palette

### 3.0.2

- Should be able to close the views with feedback from commands through the `core:cancel` command.

### 3.0.0
#### Includes massive amounts of refactoring to internal api

- Dedicated command palette for git commands. Can be opened with  
`[cmd|ctrl]-shift-h`

- `Git init` is available in projects that are not git repos.

- Stage/Unstage multiple files at a time.

- Stage individual hunks of a changed file.

- `Git checkout all files`

- Cherry pick commits.

- Can also set the path to git in settings if it isn't in PATH.

### 2.11.3

- handling null results of getRepo()

### 2.11.2

- Fix hide-output key mapping

### 2.11.1

- Minor fix, changing a call of `@pushTo` to `@execute`

### 2.11.0

 - Add hide-output keymapping

### 2.10.1

- Fix for missing fuzzaldrin reference

### 2.10.0

- `Git remove`

### 2.9.0

- `Git fetch`

### 2.8.0

- `Git log`  
  Can also configure how many commits to show in log

- `Git show` commits of current file

- Tree-view gets refreshed after things

- Polish up git tips in commit message
