/** @jsx etch.dom */
import { CompositeDisposable } from "atom";
import * as etch from "etch";

declare namespace JSX {
  interface IntrinsicElements {
    "atom-text-editor": any;
  }
}

interface Props {
  placeholderText: string;
  cancel(): void;
  onValue(value: string): void;
}

export class Input {
  private disposables = new CompositeDisposable();
  private props: Props;

  constructor(props: Props) {
    this.props = props;
    etch.setScheduler(atom.views);
    etch.initialize(this);
    this.disposables.add(
      atom.commands.add(".git-branch atom-text-editor", "core:cancel", _event => props.cancel()),
      atom.commands.add(".git-branch atom-text-editor", "core:confirm", _event => {
        const value = (this as any).refs.editor.getModel().getText();
        if (value.length > 0) props.onValue(value);
      })
    );
  }

  update(_props, _children) {
    // then call `etch.update`, which is async and returns a promise
    return etch.update(this);
  }

  async destroy() {
    await etch.destroy(this);
    this.disposables.dispose();
  }

  render() {
    return (
      <div className="git-branch">
        <atom-text-editor
          ref="editor"
          attributes={{ mini: true, placeholder: this.props.placeholderText }}
        />
      </div>
    );
  }
}
