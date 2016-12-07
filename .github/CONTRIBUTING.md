# Contributing to Git-Plus

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

If you want to read about using Atom or developing packages in Atom, the [Atom Flight Manual](http://flight-manual.atom.io) is free and available online. You can find the source to the manual in [atom/flight-manual.atom.io](https://github.com/atom/flight-manual.atom.io).

### Codebase
* Source code lives in the `lib/` directory and tests in `spec/`.
* Each git command that appears in the command palette is registered in `lib/git-plus.coffee` in the `activate` function.
  * The commands that populate the Git-plus command palette are registered in a similar fashion in `lib/git-plus-commands.coffee`. __NOTE:__ Commands that are triggered only from the tree-view context menu do not need to be declared here.
* Most commands are defined as separate modules in `lib/models`.
  * Each module usually exports a single function that takes a [git repository](https://atom.io/docs/api/v1.11.2/GitRepository) as the first argument.
  * Fundamentally, all the commands execute in a shell process. `lib/git.coffee` exports an object which is sort of the core of most of the functionality of the package. The most used function from that object is `::cmd`, which wraps Node's ChildProcess and returns a promise.
  * `::cmd` usually only needs two arguments. The first is the array of command line arguments to be used with git e.g. `['status', '--porcelain']` and an options object with a `cwd` key and value of the path to the repository. Here is a good [example](https://github.com/akonwi/git-plus/blob/master/lib/git.coffee#L112L116).
* Views are kept in `lib/views` and they are things like the inputs for some commands and selectable lists. All these views extend [atom's space-pen-views](https://github.com/atom/atom-space-pen-views).

### Pull Requests
* Follow the [CoffeeScript](#coffeescript-styleguide) styleguide.
* Include
  [Jasmine](http://jasmine.github.io/) specs in the `./spec` folder for both models and views when possible. Run them using `apm test`.
* End files with a newline.
* Place requires in the following order:
    * Built in Node Modules (such as `path`)
    * Built in Atom and Atom Shell Modules (such as `atom`, `shell`)
    * Local Modules (using relative paths)
* Avoid platform-dependent code:
    * Use `require('fs-plus').getHomeDirectory()` to get the home directory.
    * Use `path.join()` to concatenate filenames.
    * Use `os.tmpdir()` rather than `/tmp` when you need to reference the
      temporary directory.
* File names are written in `spinal-case` format.

### CoffeeScript Styleguide (taken from atom's contribution guide)
* Use camelCase
* Set parameter defaults without spaces around the equal sign
    * `clear = (count=1) ->` instead of `clear = (count = 1) ->`
* Use spaces around operators
    * `count + 1` instead of `count+1`
* Use spaces after commas (unless separated by newlines)
* Use parentheses if it improves code clarity.
* Prefer alphabetic keywords to symbolic keywords:
    * `a is b` instead of `a == b`
* Avoid spaces inside the curly-braces of hash literals:
    * `{a: 1, b: 2}` instead of `{ a: 1, b: 2 }`
* Capitalize initialisms and acronyms in names, except for the first word, which
  should be lower-case:
  * `getURI` instead of `getUri`
  * `uriToOpen` instead of `URIToOpen`
* Use `slice()` to copy an array
* Add an explicit `return` when your function ends with a `for`/`while` loop and
  you don't want it to return a collected array.
* Use `this` instead of a standalone `@`
  * `return this` instead of `return @`
* Using a plain `return` when returning explicitly at the end of a function.
    * Not `return null`, `return undefined`, `null`, or `undefined`
