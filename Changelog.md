## Changelog

### 4.4.1

- Fix for `Git status` not opening selected file when accessed outside of repo.
- Fix for some commands working after second time they are selected

### 4.4.0

- Many internal upgrades to keep up with atom 1.0.0 api
- Commands can now be run from the Git-plus palette for files in other repos outside of the current project.
  - This means you can open a directory of multiple Git repositories and work with individual repos while in the same project.

### 4.3.8

- minor

### 4.3.7

- More api upgrades
- No longer showing git commands in regular command palette when project is not a repo

### 4.3.6

- Making changes to follow the api for atom 1.0.0

### 4.3.5

- Update css selectors and keymappings with new atom API standards

### 4.3.2

- Fix for `Checkout new branch`

### 4.3.1

- `Git Show` can be cancelled with escape

### 4.3.0

- Confirm on `Git Remove`

### 4.2.6

- Handle case of no available panes after saving commit message

### 4.2.5

- Handle case of no available panes after closing commit message pane

### 4.2.4

- Minor patch

### 4.2.3

- Temporary fix for `Git Pull` issue on yosemite mac's thanks to @Azakur4.

### 4.2.2

- Remove hyphenated package name in menu

### 4.2.1

- Small fix in git-commit.coffee line 90 where promise returns a TextBuffer. Using given TextBuffer for subscriptions
rather than the 'buffer' property in the TextBuffer.

### 4.2.0

- New Git merge feature thanks to @herlon214

### 4.1.2

- Using new atom api for configs and subscribing to make it easier for moving forward and maintenance

### 4.1.1

- Fix issue of commit tab not opening
- Still need to remove dependency on Theorist

### 4.1.0

- Return of git-plus command palette

### 4.0.0

- THIS IS THE LAST PUSH OF NEW FEATURES. I'm stopping development of this package because I don't have time and on top of that, I don't use atom anymore
- Adding new command called 'Git Run'. This allows you to run git commands like in the command line. i.e. `add --all .` or `clone git@github.com:akonwi/git-plus my-git-plus`
- Removed Git-Plus command palette and merged all commands into atom command palette
- all commands are now accessible via keymappings
- Add setting to change message display time in seconds

### 3.10.4

- Fix for object names being shortened unnecessarily.

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
