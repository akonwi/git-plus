# Git-Plus package ![Build Status](https://travis-ci.org/akonwi/git-plus.svg?branch=master)

[![forthebadge](http://forthebadge.com/images/badges/uses-git.svg)](http://forthebadge.com)

vim-fugitive like package for atom. make commits and other git things without the terminal

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage

# IMPORTANT:
Make sure your gitconfig file is configured. You must configure at least the `user.email` and `user.name` variables.

Also, the package currently favors an ssh setup that doesn't expect to be prompted for credentials in order to push/pull, .etc. Github has a guide to help you set that up [here](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)

If you are on a Windows machine, I recommend checking out [this thread](https://github.com/akonwi/git-plus/issues/224) if you have issues pushing/pulling from a remote repository with this package. I also don't have the means to do my own user testing in a windows environment so I won't be immediately able to help troubleshoot windows problems.

### Showing the Git-Plus Palette
>- `Cmd-Shift-H` on MacOS
>- `Ctrl-Shift-H` on Windows + Linux
>- `Git Plus: Menu` on the atom command palette.

### Push/Pull/Fetch notifications
Notifications will appear in a console output above the status bar.
This view can be toggled by clicking the pin icon in the bottom right of the status bar.

![screenshot](https://github.com/akonwi/git-plus/raw/master/pin.png)

### Commands
_Commands are accessible for keybindings by dasherizing the command title._
> Git Add ==  `git-plus:add`

> Git Add All Commit And Push == `git-plus:add-all-commit-and-push`

  __Note: This list is not exhaustive. And if what you want isn't a feature, You can use `Git Run` and enter the command__

| Command | Effect | Default key binding |
|----------|--------|------------------
| `Git Run ` | Execute a custom command. ex. `fetch --all` | |
| `Git Status ` | Show current status. | `Cmd-Shift-A S` |
| `Git Add ` | Add the current file to the index. | `Cmd-Shift-A` |
| `Git Add All` | Adds all files to the index (ex. `git add .`). | |
| `Git Commit` | Commit the staged changes. Git-Plus will show an editor for the commit message. To make the commit, save the file. To cancel the commit, close the tab. | `Cmd-Shift-C`(*`Ctrl-Shift-X`* on Windows and Linux) |
| `Git Add And Commit` | Stages the current file before preparing a commit. (`Git add all` and `Git commit` run in succession) | `Cmd-Shift-A c` |
| `Git Add All and Commit` | Stages all changes before preparing a commit. (`Git add all` and `Git commit` in succession) | `Cmd-Shift-A a` |
| `Git Add And Commit And Push` |  Commit currently open file and push to a remote repo. | `Cmd-Shift-A Q` |
| `Git Add All Commit And Push` | Commit all changes and push to a remote repo. | `Cmd-Shift-A P` |
| `Git Commit Amend` | Amend the previous commit. |  |
| `Git Checkout Current File` | Undo changes and reset the current file to HEAD. | |
| `Git Checkout `*`[ref]`* | Change to another ref (branch or tag). | |
| `Git Checkout New branch` | Create a new branch. | |
| `Git Diff [All]` | Show the diff for the current file, or all files. The diff can either be against the staged or un-staged tree, as selected in the options. | |
| `Git` *`[Push⎮Pull]`* | Push to or pull from a remote repo. If you have multiple remote repos, you can choose which to push to or pull from. | |
| `Git Remove [current file]` | `git rm` the current file or open an selector to select the files to remove. You can select multiple files at once. | |
| `Git Log [Current File]` | Show the commit history [for the current file] and show display the selected commit. | |
| `Git Show` | Show the specified object, for example `HEAD`, `HEAD~2`,`3925a0d`, `origin/master` or `v2.7.3`. | |
| `Git Open Changed Files` | Open tabs with all added, modified or renamed files. | |
| `Git Tags` | Operate on tags individually. There are options to add, show, push, checkout, verify, and delete. | |

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
