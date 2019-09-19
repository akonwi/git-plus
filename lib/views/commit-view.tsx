import { CompositeDisposable, TextBuffer, TextEditor } from "atom";
import * as fs from "fs-plus";
import React = require("react");
import * as ReactDOM from "react-dom";
import { Repository } from "../repository";
import { Hunk } from "../utils/repository-utils";

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
  private repo: Repository;
  private editor: TextEditor;
  private stagedFiles: any[];

  constructor(props: Props) {
    this.repo = props.repo;
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
      <CommitViewContent repo={this.repo} editor={this.editor} stagedFiles={this.stagedFiles} />,
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
  repo: Repository;
  editor: TextEditor;
  stagedFiles: { mode: string; path: string }[];
}) {
  const editorRootRef = React.useRef<HTMLDivElement | null>(null);
  const [diffs, setDiffs] = React.useState<Hunk[]>([]);

  React.useEffect(() => {
    const editorElement = (props.editor as any).getElement();
    editorRootRef.current!.appendChild(editorElement);
    editorElement.focus();
  }, []);

  React.useEffect(() => {
    (async () => {
      const patches = await props.repo.getIndexDiffs();
      setDiffs(patches);
    })();
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
        <div>
          {diffs.map((diff, index) => {
            return (
              <AtomTextEditor
                key={diff.newFile}
                text={diff.text}
                readOnly
                disableDefaultLineNumbers
                keyboardInputEnabled={false}
              />
            );
            // return (
            //   <div>
            //     <div>{diff.newFile}</div>
            //     {diff.lines.map(line => {
            //       let type = "";
            //       if (line.startsWith("+")) {
            //         type = "added";
            //       } else if (line.startsWith("-")) {
            //         type = "removed";
            //       }
            //       return (
            //         <div className={`line-diff ${type !== "" ? `status-${type}` : ""}`}>{line}</div>
            //       );
            //     })}
            //   </div>
            // );
          })}
        </div>
      </div>
    </div>
  );
}

interface AtomTextEditorProps {
  text?: string;
  readOnly?: boolean;
  disableDefaultLineNumbers?: boolean;
  keyboardInputEnabled?: boolean;
  buildLineNumberLabel?(): string;
}

function AtomTextEditor(props: AtomTextEditorProps) {
  const rootRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    const buffer = new TextBuffer({ text: props.text });
    const editor = atom.workspace.buildTextEditor({
      buffer: buffer,
      readOnly: props.readOnly,
      lineNumberGutterVisible: (props.disableDefaultLineNumbers || false) !== true,
      keyboardInputEnabled: props.keyboardInputEnabled
    });

    // editor.addGutter({
    //   name: "hunk-line-number",
    //   type: "line-number",
    //   labelFn: props.buildLineNumberLabel
    // });

    if (rootRef.current) {
      rootRef.current.appendChild(editor.getElement());
    }
  }, []);

  return <div ref={rootRef} />;
}
