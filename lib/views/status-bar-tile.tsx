/** @jsx etch.dom */
import etch = require("etch");
import { ViewController } from "./controller";

interface Props {
  viewController: ViewController;
}

export class StatusBarTileView {
  element: any;

  constructor(private readonly props: Props) {
    etch.setScheduler(atom.views);
    etch.initialize(this);
    this.setupTooltip();
  }

  private setupTooltip() {
    atom.tooltips.add(this.element, { title: "Toggle Git-Plus Output" });
  }

  update(props, children) {
    return etch.update(this);
  }

  render() {
    return (
      <div className="inline-block">
        <a
          onClick={e => {
            e.preventDefault();
            this.props.viewController.getOutputView().toggle();
          }}
        >
          <span>git+</span>
        </a>
      </div>
    );
  }
}
