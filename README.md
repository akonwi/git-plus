# git-plus package

# ATTENTION!
  Development on this package is done. I no longer use atom and don't have time to maintain this project. If anyone is willing
  to pick it up or make pull requests, I'm fine with that but I won't be developing new features any longer.

[![endorse](https://api.coderwall.com/akonwi/endorsecount.png)](https://coderwall.com/akonwi)

vim-fugitive like package for atom. make commits and other git things without the terminal

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage

### Git-Plus Palette
>- `Cmd-Shift-H` on MacOS
>- `Ctrl-Shift-H` on Windows + Linux
>- `Git Plus: Menu` on the atom command palette.

### Commands
1. `Git add [all]`

  Git add will add the current file and 'add all' will add all changed files
  Default key binding: `Cmd-Shift-A`

2. `Git commit`

  Will pull up a commit message file. The commit will be made when the file is saved NOT when the pane is closed. You can just cancel by closing the tab.
  Default key binding: `Cmd-Shift-C`(*`Ctrl-Shift-X`* on Windows + Linux)

3. `Git commit amend`

  Will amend the changes to previous commit.

4. `Git checkout current file`

  Undo changes and checkout current file.

5. `Git [checkout]`

  Change branches

6. `Git Diff [All]`

  Shows diff for current file or All the files. Diff can either be with staged or unstaged as selected in options.

7. `Git new branch`

  Create a new branch

8. `Git [push|pull]`

  When Pushing, if you have multiple remote repos, you can choose which to push to.
9. `Git Add and Commit`

  Add the current file and pull up the commit message file. Similar to `Git add` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A c`

10. `Git Add All and Commit`

  Add all changed files and pull up the commit message file. Similar to `Git add all` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A a`

11. `Git rm [current file]`

  Git rm the current file or open an selector to select the files to remove. You can select multiple files at once.

12. `Git Log [Current File]`

  Show the commit history [for the current file] and show display the selected commit.

13. `Git Show`

  Show the specified object, for example `HEAD`, `HEAD~2`, `3925a0d`, `origin/master` or `v2.7.3`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
