import { Dock, WorkspaceCenter } from "atom";
import { GitPlusPackage } from "../package";
import { OutputViewContainer } from "./output-view/container";

function isDock(container: Dock | WorkspaceCenter): container is Dock {
  return (container as any).getLocation() !== "center";
}

export class ViewController {
  private outputView?: OutputViewContainer;

  constructor(private pkg: GitPlusPackage) {
    atom.workspace.addOpener(uri => {
      if (uri === OutputViewContainer.URI) {
        return this.getOutputView();
      }
    });
  }

  getOutputView() {
    if (!this.outputView) {
      this.outputView = new OutputViewContainer(this.pkg.logger);
      this.outputView.onDidDestroy(() => {
        this.outputView = undefined;
      });
    }
    return this.outputView;
  }

  isVisible(uri: string) {
    const container = atom.workspace.paneContainerForURI(uri);
    if (container) {
      const activeItem = container.getActivePaneItem() as any | undefined;
      if (!activeItem) return false;
      const viewIsActive = activeItem.getURI && activeItem.getURI() === uri;
      if (isDock(container)) {
        return container.isVisible() && viewIsActive;
      }
      return viewIsActive;
    }
    return false;
  }
}
