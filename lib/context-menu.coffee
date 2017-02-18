module.exports = ->
  atom.contextMenu.add {
    '.tree-view.full-menu .file, .tree-view.full-menu .directory': [
      { type: 'separator'},
      'label': 'Git',
      'submenu': [
        {
          label: 'Git add',
          'command': 'git-plus-context:add'
        },
        {
          label: 'Git add + commit',
          'command': 'git-plus-context:add-and-commit'
        },
        {
          label: 'Git checkout',
          'command': 'git-plus-context:checkout-file'
        },
        {
          label: 'Git diff',
          'command': 'git-plus-context:diff'
        },
        {
          label: 'Git diff branches',
          'command': 'git-plus-context:diff-branches'
        },
        {
          label: 'Git diff branche files',
          'command': 'git-plus-context:diff-branch-files'
        },
        {
          label: 'Git difftool',
          'command': 'git-plus-context:difftool'
        },
        {
          label: 'Git pull',
          'command': 'git-plus-context:pull'
        },
        {
          label: 'Git push',
          'command': 'git-plus-context:push'
        },
        {
          label: 'Git push --set-upstream',
          'command': 'git-plus-context:push-set-upstream'
        },
        {
          label: 'Git unstage',
          'command': 'git-plus-context:unstage-file'
        }
      ],
      { type: 'separator'}
    ],
    'atom-text-editor:not(.mini)': [
      {
        'label': 'Git add file'
        'command': 'git-plus:add'
      }
    ]
  }
