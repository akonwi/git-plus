# git-plus package

[![endorse](https://api.coderwall.com/akonwi/endorsecount.png)](https://coderwall.com/akonwi)

vim-fugitive like package for atom. make commits and other git things without the terminal

![A screenshot of your spankin' package](https://raw.githubusercontent.com/akonwi/git-plus/master/commit.gif)

## Usage
1. `Git add [all]`

  Git add will add the current file and 'add all' will add all changed files
  Default key binding: `Cmd-Shift-A`

2. `Git commit`

  Will pull up a commit message file. The commit will be made when the file is saved NOT when the pane is closed. You can just cancel by closing the tab.
  Default key binding: `Cmd-Shift-C`

3. `Git [checkout]`

  Change branches

4. `Git new branch`

  Create a new branch

4. `Git [push|pull]`

  When Pushing, if you have multiple remote repos, you can choose which to push to.

5. `Git Add and Commit`

  Add the current file and pull up the commit message file. Similar to `Git add` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A c`

6. `Git Add All and Commit`

  Add all changed files and pull up the commit message file. Similar to `Git add all` and `Git commit` in succession.
  Default key binding: `Cmd-Shift-A a`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
