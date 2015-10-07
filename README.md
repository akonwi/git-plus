# Git-Plus package ![Build Status](https://travis-ci.org/akonwi/git-plus.svg?branch=5.5.0)

[![endorse](https://api.coderwall.com/akonwi/endorsecount.png)](https://coderwall.com/akonwi)

vim-fugitive like package for atom. make commits and other git things without the terminal

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage

# IMPORTANT: Make sure your gitconfig file is configured or at least your `user.email` and `user.name` variables are initialized

### Git-Plus Palette
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

  __Note: This list is not exclusive__

1. `Git add [all]`

  Git add will add the current file and 'add all' will add all changed files
  Default key binding: `Cmd-Shift-A`

2. `Git add all commit and push`

  `Cmd-Shift-A P`

3. `Git commit`

  Will pull up a commit message file. The commit will be made when the file is saved NOT when the pane is closed. You can just cancel by closing the tab.
  Default key binding: `Cmd-Shift-C`(*`Ctrl-Shift-X`* on Windows + Linux)

4. `Git commit amend`

  Will amend the changes to previous commit.

5. `Git checkout current file`

  Undo changes and checkout current file.

6. `Git [checkout]`

  Change branches

7. `Git Diff [All]`

  Shows diff for current file or All the files. Diff can either be with staged or unstaged as selected in options.

8. `Git new branch`

  Create a new branch

9. `Git [push|pull]`

  When Pushing, if you have multiple remote repos, you can choose which to push to.
10. `Git Add and Commit`

  Add the current file and pull up the commit message file. Similar to `Git add` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A c`

11. `Git Add All and Commit`

  Add all changed files and pull up the commit message file. Similar to `Git add all` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A a`

12. `Git rm [current file]`

  Git rm the current file or open an selector to select the files to remove. You can select multiple files at once.

13. `Git Log [Current File]`

  Show the commit history [for the current file] and show display the selected commit.

13. `Git Show`

  Show the specified object, for example `HEAD`, `HEAD~2`, `3925a0d`, `origin/master` or `v2.7.3`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests
4. Make your changes
5. Run `apm test`
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request
