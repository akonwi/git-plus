# Git-Plus Package ![Build Status](https://travis-ci.org/akonwi/git-plus.svg?branch=5.5.0)

[![endorse](https://api.coderwall.com/akonwi/endorsecount.png)](https://coderwall.com/akonwi)

Vim-fugitive like package for Atom. Make commits and other Git commands without a terminal.

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage

> #### IMPORTANT:
> Make sure your `gitconfig` file is configured. You must configure at least the `user.email` and `user.name` variables.

Also, the package currently favors a SSH setup that doesn't expect to be prompted for credentials in order to push/pull, etc.

#### Showing the Git-Plus Palette
>- `Cmd-Shift-H` on Mac OS X
>- `Ctrl-Shift-H` on Linux & Windows
>- `Git Plus: Menu` on the Atom's Command Palette.

#### Push, Pull & Fetch Notifications
Notifications will appear in the console output above the status bar.
This view can be toggled by clicking the pin icon in the bottom right of the status bar.

![screenshot](https://raw.githubusercontent.com/akonwi/git-plus/5.5.0/pin.png)

#### Commands
_Commands are accessible for keybindings by dasherizing the command title._
> Git Add ==  `git-plus:add`

> Git Add All Commit And Push == `git-plus:add-all-commit-and-push`


__Note: This list is not exhaustive. And if what you want isn't a feature, You can use `Git Run` and enter the command__

| Command | Effect | Default key binding |
|----------|--------|------------------
| `Git Run ` | Runs a custom command. ex. `fetch --all` | |
| `Git Status ` | Shows current status. | `Cmd-Shift-A S` |
| `Git Add ` | Adds the current file. | `Cmd-Shift-A` |
| `Git Add All` | Adds all changed files. | |
| `Git Add All Commit and Push` | Commits every changed file and then, push to a remote repository. | `Cmd-Shift-A P` |
| `Git Commit` | Commits the staged changes. Git-Plus shows a commit message editor. To make the commit, save the file. To cancel the commit, close the tab. | `Cmd-Shift-C`(*`Ctrl-Shift-X`* on Windows and Linux) |
| `Git Commit Amend` | Amends the changes to previous commit. |  |
| `Git Checkout [current file]` | Undo changes and checkout the current file. | |
| `Git Checkout [ref]` | Changes to another ref (branch or tag). | |
| `Git Diff [all]` | Shows the diff for the current or all files. The diff can either be against the staged or unstaged tree, as selected in the options. | |
| `Git New Branch` | Creates a new branch. | |
| `Git [push] & [pull]` | Pushes to or pull from a remote repo. If you have multiple remote repositories, you can choose which to push to or pull from. | |
| `Git Add and Commit` | Adds current changed file and show the commit message file. Similar to `Git Add`, but runs `Git Commit` in succession. | `Cmd-Shift-A c` |
| `Git Add All and Commit` | Adds all changed files and show the commit message file. Similar to `Git Add All`, but runs `Git Commit` in succession. | `Cmd-Shift-A a` |
| `Git RM [current file]` | Removes the current file or open a selector that shows files to remove. You can select multiple files at once. | |
| `Git Log [current file]` | Shows current file's commit history and display the selected commit. | |
| `Git Show` | Shows the specified object. e.g.: `HEAD`, `HEAD~2`,`3925a0d`, `origin/master`, `v2.7.3`. | |

#### Commit window
To change where the commit window appears go to settings and find:
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
