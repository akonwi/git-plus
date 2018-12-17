const fileSelector = ".tree-view > .full-menu .file";
const directorySelector = ".tree-view > .full-menu .directory";
const projectRootSelector = ".tree-view .header.list-item.project-root-header"; // unfortunately, there's no indicator on the .list-item of whether it's a git repo
const modifiedFile = ".entry.file.status-modified";
const modifiedDirectory = ".entry.directory.status-modified > .list-item";

//     '.tree-view .multi-select': [
//       'label': 'Git',
//       'submenu': [
//         {label: 'Git push', 'command': 'git-plus-context:push'}
//       ]
//     ]
//     'atom-text-editor:not(.mini)': [
//       {
//         'label': 'Git add file'
//         'command': 'git-plus:add'
//       }
//     ]
//   }
export function initializeContextMenu() {
  atom.contextMenu.add({
    // modified files and directories
    [`${modifiedFile}, ${modifiedDirectory}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Add", command: "git-plus-context:add" },
          { label: "Add + Commit", command: "git-plus-context:add-and-commit" },
          { label: "Checkout", command: "git-plus-context:checkout-file" },
          {
            label: "Unstage",
            command: "git-plus-context:unstage-file"
          }
        ]
      },
      { type: "separator" }
    ],
    // modified files
    [modifiedFile]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [{ label: "Diff", command: "git-plus-context:diff" }]
      },
      { type: "separator" }
    ],
    // all files
    [fileSelector]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [{ label: "Diff Against Branch", command: "git-plus-context:diff-branch-files" }]
      },
      { type: "separator" }
    ],
    // all files and directories
    [`${fileSelector},${directorySelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [{ label: "Difftool", command: "git-plus-context:difftool" }]
      },
      { type: "separator" }
    ],
    // root directory
    [projectRootSelector]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Diff", command: "git-plus-context:diff-all" },
          {
            label: "Diff Branches",
            command: "git-plus-context:diff-branches"
          },
          { label: "Pull", command: "git-plus-context:pull" },
          { label: "Push", command: "git-plus-context:push" }
        ]
      },
      { type: "separator" }
    ]
  });
}
