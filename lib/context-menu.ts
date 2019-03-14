// const fileSelector = ".tree-view > .full-menu .file";
const notMultiSelectedFileSelector = ".tree-view > .full-menu:not(.multi-select) .file";
const notMultiSelectedSelector = ".tree-view-root:not(.multi-select)";
const multiSelectedSelector = ".tree-view-root.multi-select";
const projectRootSelector = ".header.list-item.project-root-header"; // unfortunately, there's no indicator on the .list-item of whether it's a git repo
const modifiedFileSelector = ".entry.file.status-modified";
const modifiedDirectorySelector = ".entry.directory.status-modified > .list-item";

export function initializeContextMenu() {
  atom.contextMenu.add({
    // modified files and directories
    [`${notMultiSelectedSelector} ${modifiedFileSelector}, ${notMultiSelectedSelector} ${modifiedDirectorySelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Add", command: "git-plus-context:add" },
          { label: "Add + Commit", command: "git-plus-context:add-and-commit" },
          { label: "Checkout", command: "git-plus-context:checkout-file" },
          { label: "Difftool", command: "git-plus-context:difftool" },
          {
            label: "Unstage",
            command: "git-plus-context:unstage-file"
          }
        ]
      },
      { type: "separator" }
    ],
    // modified files
    [`${notMultiSelectedSelector} ${modifiedFileSelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [{ label: "Diff", command: "git-plus-context:diff" }]
      },
      { type: "separator" }
    ],
    // all files
    [notMultiSelectedFileSelector]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [{ label: "Diff Against Branch", command: "git-plus-context:diff-branch-files" }]
      },
      { type: "separator" }
    ],
    [`${multiSelectedSelector} ${modifiedFileSelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Add", command: "git-plus-context:add" },
          {
            label: "Unstage",
            command: "git-plus-context:unstage-file"
          }
        ]
      },
      { type: "separator" }
    ],
    // all files and directories
    // root directory
    [`${notMultiSelectedSelector} ${projectRootSelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Diff", command: "git-plus-context:diff-all" },
          {
            label: "Diff Branches",
            command: "git-plus-context:diff-branches"
          }
        ]
      },
      { type: "separator" }
    ],
    [`${multiSelectedSelector} ${projectRootSelector}, ${notMultiSelectedSelector} ${projectRootSelector}`]: [
      { type: "separator" },
      {
        label: "Git",
        submenu: [
          { label: "Add", command: "git-plus-context:add" },
          { label: "Pull", command: "git-plus-context:pull" },
          { label: "Push", command: "git-plus-context:push" }
        ]
      },
      { type: "separator" }
    ]
  });
}
