## Changelog

### 5.25.1
- Use experimental toggle: 'Always Pull From Upstream', when pulling before pushing is enabled

### 5.25.0
- Adds new experimental toggle: 'Always Pull From Upstream', which will pull from your current branch upstream automatically without prompting you for a branch to pull from.
- Fix [#538](https://github.com/akonwi/git-plus/issues/538)
  - [#537](https://github.com/akonwi/git-plus/issues/537) has been left open as the original.

### 5.24.2
- Fix [#436](https://github.com/akonwi/git-plus/issues/436)
- Fix [#529](https://github.com/akonwi/git-plus/issues/529)

### 5.24.1
- Fix [#515](https://github.com/akonwi/git-plus/issues/515)
- Fix [#533](https://github.com/akonwi/git-plus/issues/533)

### 5.24.0
- This enables basic support for submodules. You should be able to add, commit, and diff files that belong to submodules.
- Small performance improvements for initial loading of the package's command palette.

### 5.23.3
- Add new command, `Commit All and Push`
- Fix [#509](https://github.com/akonwi/git-plus/issues/509) where multiple selected commits weren't being cherry picked.
- Update README
  - Table of commands contains info about using Tags.
  - Add note for Windows users to check out [#224](https://github.com/akonwi/git-plus/issues/224) for troubleshooting pull/push problems

### 5.23.2
- Fix #459 [pr #459](https://github.com/akonwi/git-plus/issues/459)
  - Output from commands executed by Git Run will be colored if git provides coloring

### 5.22.1
- Fix #448 [pr #514](https://github.com/akonwi/git-plus/issues/448)
- Fix #517 [pr #514](https://github.com/akonwi/git-plus/issues/517)

### 5.22.0
- Adds a new command to do `git push -u`.
  - The old push command automatically retried after a failure with the `-u` flag and that can completely ignore some pre-push hooks. Fixes [#422](https://github.com/akonwi/git-plus/issues/422)
- Files can now be staged from the Tree-view with a Git add command in the context menu from right clicking files and folders.
  - More commands can be added there with pull requests. See [#422](https://github.com/akonwi/git-plus/issues/422)
  - This work also fixes an unreported bug where trying to open a difftool for a file from the tree-view that was different than the currently active file would not work.

### 5.21.0
- Includes a format option for the Git Show command in package settings. [pr #527](https://github.com/akonwi/git-plus/issues/527)

### 5.20.0
- Fix #510 [pr #514](https://github.com/akonwi/git-plus/issues/514)
- Add new command (Add Modified) [pr #519](https://github.com/akonwi/git-plus/issues/519)

### 5.19.0
- Add new command (Merge without fast-forward) [pr #492](https://github.com/akonwi/git-plus/issues/492)

### 5.18.3
- Merge [pr #489](https://github.com/akonwi/git-plus/issues/489)

### 5.18.2
- Git show defaults to HEAD if input is left empty. [pr #481](https://github.com/akonwi/git-plus/issues/481)
- Pin icon in status bar can now be disabled. [pr #488](https://github.com/akonwi/git-plus/issues/488)

### 5.18.0
- Enable activating the difftool on files and folders in the tree-view [pr #508](https://github.com/akonwi/git-plus/issues/508)
- Allow the package to initialize immediately when atom loads

### 5.17.1
- Fix bugs with new diff highlighting [#511](https://github.com/akonwi/git-plus/issues/511)

### 5.17.0
- Add syntax highlighting to diffs [#507](https://github.com/akonwi/git-plus/issues/507)
- Improves diff grammar and styling [#507](https://github.com/akonwi/git-plus/issues/507)

### 5.16.2
- Fix [#476](https://github.com/akonwi/git-plus/issues/476)

### 5.16.1
- Fix [#472](https://github.com/akonwi/git-plus/issues/472)

### 5.16.0
- Add toggle for experimental features in package settings
- Verbose commits is now an experimental feature([#90](https://github.com/akonwi/git-plus/issues/90))

### 5.15.0
- New command to 'Add and commit and push' (@john-d-murphy)[#452](https://github.com/akonwi/git-plus/issues/452)
- New command 'Open all changed files' (@flexoid) [#463](https://github.com/akonwi/git-plus/issues/463)

### 5.14.0
- Add a new stash command to save with a message -> [#396](https://github.com/akonwi/git-plus/issues/396)
- Fix placeholder text for Run command not displaying

### 5.13.6
- Fix [#445](https://github.com/akonwi/git-plus/issues/445)

### 5.13.5
- Fix [#412](https://github.com/akonwi/git-plus/issues/412)
- Slight refactor to diff grammar

### 5.13.4
- Fix [#423](https://github.com/akonwi/git-plus/issues/423)

### 5.13.3
- Show errors when Add and Push commands fail

### 5.13.0
- Add keyboard support for git log view (@aki77)[PR#389](https://github.com/akonwi/git-plus/pull/389)

### 5.12.3
- Fix [#387](https://github.com/akonwi/git-plus/issues/387)
- Fix [#383](https://github.com/akonwi/git-plus/issues/383)
- Fix [#369](https://github.com/akonwi/git-plus/issues/369)

### 5.12.1
- Merge [pr #380](https://github.com/akonwi/git-plus/issues/380)
- Merge [pr #381](https://github.com/akonwi/git-plus/issues/381)
 - Fixes [#372](https://github.com/akonwi/git-plus/issues/372)
- Fix [#377](https://github.com/akonwi/git-plus/issues/377)

### 5.12.0
- Add `Merge Remote` command (@crshd)
- Fix [#370](https://github.com/akonwi/git-plus/issues/370)
- Fix [#371](https://github.com/akonwi/git-plus/issues/371)
- Remove code that 'fixed' [#90](https://github.com/akonwi/git-plus/issues/90) because there are still gaps to figure out

### 5.11.0
- Fix [#355](https://github.com/akonwi/git-plus/issues/355)
- Fix [#354](https://github.com/akonwi/git-plus/issues/354)
- Fix [#358](https://github.com/akonwi/git-plus/issues/358)

### 5.9.0
- Fix a bug where the commit amend file didn't show the status of the previous
commit if there were no new changed files
- Fix for a blank uncommented line inside the status of the amend file
- Fix syntax error in the amend file. Changed 'removed' to 'deleted'

### 5.8.3
- Show errors from `Diff` command

### 5.8.2
- Fix for no notifications when changing branches

### 5.8.1
- Remove verbose commit feature because it isn't fully implemented

### 5.8.0
- Add setting for verbose commit panes

### 5.7.1
- Fix #349 (@joshbaldock)

### 5.7.0
- Added config options for pulling before pushing

### 5.6.10
- Fix #340 (@brettle)

### 5.6.8
- Fix #322 (@teefax)
- Change format of list of commands in README (@capncodewash)

### 5.6.6
- Fix #322 (@mightydok)
- Make all notifications dismissable (@jamen)
- Fix height for long log outputs (@sxasraf)

### 5.6.5
- Trigger checkout from clicking on branch name in status bar on atom-workspace
- Update splitPaneDirection config to be an enum

### 5.6.3
- Fix #318

### 5.6.2
- Disable color for 'Git show' (@modosc)

### 5.6.1
- Display untracked files in list of files to stage as separate items

### 5.6.0
- Fix #270. When pulling, you now have the default option to pull from the origin of the current branch

### 5.5.7
- Fix #317 and #319

### 5.5.6
- Fix #315

### 5.5.5
- Complete fix for #310

### 5.5.4
- Refactor
- Try to ignore CRLF errors when commiting

### 5.5.3
- Fix #311

### 5.5.2
- Refactoring
- Catch unstage files errors

### 5.5.0
- A lot of refactoring into promises
- __Output console__
  - Add toggle on the right of status-bar for toggling the output console
  - Output from `Git Run` will be displayed in the output console
  - Show notification when Push/Pull/Fetch starts in the output console
  - Show bigger messages like results of stash/merge in output console
- Clicking on the branch name in the status-bar will trigger the `Git Checkout` menu (@kandros)
- Amending no longer resets HEAD so you can safely cancel an amend
- __`Add All Commit And Push`__
  - is now an activation command (@dbenson24)
  - it tries to `pull` before pushing (@mhuggins7278)
- Add `Git Difftool` to open up a difftool (@outsmirkable)
- Add `Git Rebase` (@afontaine)

### 5.4.7
- #269

### 5.4.6
 - Refactor to fix #266

### 5.4.5
- #265

### 5.4.4
- #263

### 5.4.3
- Add deactivate method to package
- Refactoring

### 5.4.2
- #261

### 5.4.1
- #260: Destroy 'COMMIT_EDITMSG' pane not just editor

### 5.4.0
- #201: Add `Commit All` command. Equivalent of `git commit -a`

### 5.3.5
- #209: Only destroy textEditor for 'COMMIT_EDITMSG'

### 5.3.4
- unlink COMMIT_EDITMSG file after commits
- Respect no 'open pane' setting with commit window

### 5.3.3
- #231: Shift-Enter confirms stage/unstage in dialogs

### 5.3.2
- Fix #226: remove COMMIT_EDITMSG file from repo when committing
- Fix #228: Don't show color codes in diff when `color.ui=always`

### 5.3.0
- Fix #233 (@hotoiledgoblins)
- Add 'Git checkout remote' to atom command palette
- Respect `commit.template` config option

### 5.2.4
- Fix #243
- Fix #42
- Add 'push' command to context menu

### 5.2.3
- Make git-diff highlighting non-greedy. Thanks to @Victorystick

### 5.2.2

- fix 'Git log current file'

### 5.2.1

- add support for Git pull using rebase (@maxcnunes)
- Git diff opens panes with respect to the 'open in pane' setting
- Commit and diff won't explode if you don't have the spit panes option selected

### 5.1.7

- Git log command now works with submodules and different repos
- new command: `Remote Checkout`

### 5.1.2

- #206: Fix for commit file syntax highlighting not working sometimes. (@Gwasanaethau)

### 5.1.1

- Fix for commands not working in submodules
- Fix typos with 'Git Fetch Prune' (@Azakur4)

### 5.1.0

- The Split Pane direction setting actually works now.
  > Possible choices are [right up down left]. Defaults to right.

### 5.0.7

- Fix #199
- Fix #198
- Fix #197

### 5.0.4

- Fix typo of 'notifer' to 'notifier'
- Fix issue #139

### 5.0.3

- Treeview and StatusBar should update after git commands
- No longer opening blank file on `Git show` if given an invalid object

### 5.0.2

- Fix typo of 'notifer' to 'notifier'
- Brought back the `messageTimeout` setting for remaining StatusViews

### 5.0.1

- Major release to be compatible with atom 1.0.0
- If a window has more than one project with a git repository and a command is attempted,
  then you can choose which repo to manipulate.
- New layout for commits in `Git log` command
- Most StatusViews of command output have been moved to the new notificaton system in atom

### 4.5.0

- Remove some more deprecations (@Azakur4)
- New command `Git Add All Commit And Push` (@TwanoO67)

### 4.4.13

- bug fix for those using 1.0.0 preview

### 4.4.12

- bug fix, issue #175

### 4.4.11

- Remove deprecated api code
- Add keywords to package.json
- Fix refreshing git status after commands to update ui
- Remove 'emissary' module because it does not work in helping Status and Output views listen for global events

### 4.4.10

- Remove uses of `atom.project.getRepo()`

### 4.4.9

- Refactoring
- Fixes issue #173

### 4.4.8

- Proper fix for GitRepository trying to refresh on window focus by setting `refreshOnWindowFocus` to false

### 4.4.7

- Update style selectors for diff highlighting

### 4.4.6

- Try to keep only one instance of GitRepository floating around by using either
`atom.project.getRepo` or calling `::destroy` on an opened instance

### 4.4.2

- Gracefully handle `Git not found error` thanks to @TrangPham.
- Fix for files not opening when selected from status list

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
