import { Emitter } from "atom";
import * as React from "react";
import * as ReactDOM from "react-dom";
import { ActivityLogger } from "../../activity-logger";
import { Root } from "./Root";

export class OutputViewContainer {
  static URI = "git-plus://output-view";

  element: HTMLElement;
  private emitter = new Emitter();
  private logger: ActivityLogger;

  constructor(logger: ActivityLogger) {
    this.logger = logger;
    this.element = document.createElement("div");
    this.element.classList.add("git-plus", "output");
    this.render();
    atom.workspace.open(this, { activatePane: false });
  }

  getURI() {
    return OutputViewContainer.URI;
  }

  getTitle() {
    return "Git+";
  }

  getDefaultLocation() {
    return "bottom";
  }

  serialize() {
    return {
      deserializer: "git-plus/output-view"
    };
  }

  async show() {
    const focusedPane = atom.workspace.getActivePane();
    await atom.workspace.open(this, { activatePane: true });
    if (focusedPane && !focusedPane.isDestroyed()) focusedPane.activate();
  }

  hide() {
    atom.workspace.hide(this);
  }

  render() {
    ReactDOM.render(<Root logger={this.logger} />, this.element);
  }

  toggle() {
    atom.workspace.toggle(this);
  }

  destroy() {
    ReactDOM.unmountComponentAtNode(this.element);
    this.element.remove();
    this.emitter.emit("did-destroy");
  }

  onDidDestroy(cb: () => void) {
    return this.emitter.on("did-destroy", cb);
  }
}
