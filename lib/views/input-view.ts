import { CompositeDisposable } from "atom";
import * as etch from "etch";

export const $ = etch.dom;

export class Etch<Props = void, Children = void> {
  props: Props;
  children: Children;
  readonly refs: any;

  constructor(props: Props, children: Children) {
    this.props = props;
    this.children = children;
    etch.initialize(this);
  }

  update(props?: Props, children?: any) {
    if (props == null) return etch.update(this);
    this.props = props;
    this.children = children;
    etch.update(this);
  }

  destroy() {
    etch.destroy(this);
  }
}

interface InputProps {
  placeholder?: string;
  onSubmit(value: string): void;
  onCancel(): void;
}

export class InputView extends Etch<InputProps> {
  private subscriptions = new CompositeDisposable();

  constructor(props: InputProps) {
    super(props);
    this.subscriptions.add(
      atom.commands.add(".git-plus-input atom-text-editor", "core:confirm", () => {
        props.onSubmit((this.refs.editor as any).getModel().getText());
      }),
      atom.commands.add(".git-plus-input atom-text-editor", "core:cancel", () => props.onCancel())
    );
  }

  destroy() {
    super.destroy();
    this.subscriptions.dispose();
  }

  render() {
    return $(
      "div",
      { className: "git-plus-input" },
      $("atom-text-editor", {
        ref: "editor",
        attributes: { mini: true, "placeholder-text": this.props.placeholder }
      })
    );
  }
}
