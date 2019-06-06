import { CompositeDisposable, TextEditor } from "atom";
import * as fs from "fs-plus";
import { useEffect, useRef } from "react";
import React = require("react");
import * as ReactDOM from "react-dom";
import { Repository } from "../repository";

const statusText = {
  M: "modified",
  A: "added",
  D: "removed",
  R: "renamed"
};

const getTemplate = function(filePath?: string) {
  if (!filePath) return "";
  else {
    try {
      return fs
        .readFileSync(fs.absolute(filePath.trim()))
        .toString()
        .trim();
    } catch (e) {
      atom.notifications.addWarning("Your configured commit template file can't be found.");
      return "";
    }
  }
};

interface Props {
  repo: Repository;
  stagedFiles: any[];
  onDidCancel(): void;
  onDidSave(text: string): void;
}

export class CommitView {
  static URI = "git-plus://commit/new";

  private subscriptions = new CompositeDisposable();
  readonly element: HTMLDivElement;
  private editor: TextEditor;
  private stagedFiles: any[];

  constructor(props: Props) {
    this.editor = atom.workspace.buildTextEditor({});
    this.stagedFiles = props.stagedFiles;
    this.element = document.createElement("div");

    this.subscriptions.add(
      atom.commands.add(".git-plus-commit-view__editor", "core:save", () => {
        props.onDidSave(this.editor.getText());
      }),
      this.editor.onDidDestroy(() => {
        props.onDidCancel();
        this.destroy();
      })
    );

    {
      const subscription = atom.workspace.onDidOpen(event => {
        if (event.uri === this.getURI()) {
          // terrible, just terrible
          // necessary to make vim-mode-plus (and probably others) aware of it
          (atom.workspace as any).emitter.emit("did-add-text-editor", {
            ...event,
            textEditor: this.editor
          });
          subscription.dispose();
          (this.editor as any).getElement().focus();
        }
      });
    }

    (this.editor.getBuffer() as any).setLanguageMode(
      (atom.grammars as any).languageModeForGrammarAndBuffer(
        atom.grammars.grammarForScopeName("text.git-commit"),
        this.editor.getBuffer()
      )
    );
    const template = getTemplate(props.repo.getConfig("commit.template"));
    this.editor.setText(template);
    this.render();
  }

  render() {
    ReactDOM.render(
      <CommitViewContent editor={this.editor} stagedFiles={this.stagedFiles} />,
      this.element
    );
  }

  getURI() {
    return CommitView.URI;
  }

  getTitle() {
    return "Commit";
  }

  destroy() {
    this.subscriptions.dispose();
  }
}

function CommitViewContent(props: {
  editor: TextEditor;
  stagedFiles: { mode: string; path: string }[];
}) {
  const editorRootRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const editorElement = (props.editor as any).getElement();
    editorRootRef.current!.appendChild(editorElement);
    editorElement.focus();
  }, []);

  return (
    <div>
      <div ref={editorRootRef} className="git-plus-commit-view__editor" />
      <div className="git-plus-index-view">
        <div>
          <span>Files staged for this commit:</span>
          <ul className="list-group">
            {props.stagedFiles.map((file, i) => (
              <li key={i} className="list-item">
                <span className={`inline-block status-${statusText[file.mode]}`}>
                  <span className={`icon icon-diff-${statusText[file.mode]}`}>{file.path}</span>
                </span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

// const defaultParams = {};
// function useTextEditor(target: HTMLElement, params: { buffer?: TextBuffer } = defaultParams) {
//   useEffect(() => {
//     const editor = atom.workspace.buildTextEditor(params);
//     return () => {
//       editor.destroy();
//     };
//   }, []);
// }
