import { Dock, Emitter, WorkspaceCenter } from "atom";
import * as React from "react";
import * as ReactDOM from "react-dom";
import { Root } from "./Root";

function isDock(container: Dock | WorkspaceCenter): container is Dock {
  return (container as any).getLocation() !== "center";
}

const DID_DESTROY = "did-destroy";

export class OutputViewContainer {
  static URI = "git-plus://output-view";

  private emitter = new Emitter();
  element: HTMLElement;

  constructor() {
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
    ReactDOM.render(<Root container={this} />, this.element);
  }

  toggle() {
    atom.workspace.toggle(this);
  }

  destroy() {
    ReactDOM.unmountComponentAtNode(this.element);
    this.element.remove();
    this.emitter.emit(DID_DESTROY);
    this.emitter.dispose();
  }

  onDidDestroy(cb: () => void) {
    return this.emitter.on(DID_DESTROY, cb);
  }

  static isVisible() {
    const container = atom.workspace.paneContainerForURI(OutputViewContainer.URI);
    if (container) {
      const activeItem = container.getActivePaneItem();
      const viewIsActive = activeItem instanceof OutputViewContainer;
      if (isDock(container)) {
        return container.isVisible() && viewIsActive;
      }
      return viewIsActive;
    }
    return false;
  }
}
