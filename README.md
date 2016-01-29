# Git-Plus package ![Build Status](https://travis-ci.org/akonwi/git-plus.svg?branch=5.5.0)

[![endorse](https://api.coderwall.com/akonwi/endorsecount.png)](https://coderwall.com/akonwi)

vim-fugitive like package for atom. make commits and other git things without the terminal

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage

# IMPORTANT:
Make sure your gitconfig file is configured. You must configure at least the `user.email` and `user.name` variables.

Also, the package currently favors an ssh setup that doesn't expect to be prompted for credentials in order to push/pull, .etc.

### Showing the Git-Plus Palette
>- `Cmd-Shift-H` on MacOS
>- `Ctrl-Shift-H` on Windows + Linux
>- `Git Plus: Menu` on the atom command palette.

### Push/Pull/Fetch notifications
Notifications will appear in a console output above the status bar.
This view can be toggled by clicking the pin icon in the bottom right of the status bar.

![screenshot](https://raw.githubusercontent.com/akonwi/git-plus/5.5.0/pin.png)

### Commands
_Commands are accessible for keybindings by dasherizing the command title._
> Git Add ==  `git-plus:add`

> Git Add All Commit And Push == `git-plus:add-all-commit-and-push`

  __Note: This list is not exhaustive. And if what you want isn't a feature, You can use `Git Run` and enter the command__

| Command | Effect | Default key binding |
|----------|--------|------------------
| `Git Run ` | Execute a custom command. ex. `fetch --all` | |
| `Git Status ` | Show current status. | `Cmd-Shift-A S` |
| `Git Add ` | Add the current file. | `Cmd-Shift-A` |
| `Git Add All` | Adds all changed files. | |
| `Git add all commit and push` | Commit every changed file and push to a remote repo. | `Cmd-Shift-A P` |
| `Git commit` | Commit the staged changes. Git-Plus shows a commit message editor. To make the commit, save the file. To cancel the commit, close the tab. | `Cmd-Shift-C`(*`Ctrl-Shift-X`* on Windows and Linux) |
| `Git commit amend` | Amend the changes to previous commit. |  |
| `Git checkout current file` | Undo changes and checkout the current file. | |
| `Git Checkout `*`[ref]`* | Change to another ref (branch or tag). | |
| `Git Diff [All]` | Show the diff for the current file, or all files. The diff can either be against the staged or un-staged tree, as selected in the options. | |
| `Git new branch` | Create a new branch. | |
| `Git` *`[push⎮pull]`* | Push to or pull from a remote repo. If you have multiple remote repos, you can choose which to push to or pull from. | |
| `Git Add and Commit` | Add all changed files and show the commit message file. Similar to `Git add all` and `Git commit` run in succession. | `Cmd-Shift-A c` |
| `Git Add All and Commit` | Add all changed files and show the commit message file. Similar to `Git add all` and `Git commit` in succession. | `Cmd-Shift-A a` |
| `Git rm [current file]` | `git rm` the current file or open an selector to select the files to remove. You can select multiple files at once. | |
| `Git Log [Current File]` | Show the commit history [for the current file] and show display the selected commit. | |
| `Git Show` | Show the specified object, for example `HEAD`, `HEAD~2`,`3925a0d`, `origin/master` or `v2.7.3`. | |

### Commit window
To change where the commit window appears go to settings and find
![screenshot](http://imgur.com/cdc7M5p.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests
4. Make your changes
5. Run `apm test`
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request
