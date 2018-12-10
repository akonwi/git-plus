import cx from "classnames";
import * as linkify from "linkify-urls";
import * as React from "react";
import { Record } from "../../activity-logger";

interface Props {
  record: Record;
  isLatest: boolean;
  ansiConverter: { toHtml(ansi: string): string };
}

interface State {
  collapsed: boolean;
}

export class Entry extends React.Component<Props, State> {
  userToggled = false;

  constructor(props: Props) {
    super(props);
    this.state = {
      collapsed:
        atom.config.get("git-plus.general.alwaysOpenDockWithResult") && props.isLatest
          ? false
          : true
    };
  }

  componentDidUpdate(prevProps: Props, prevState: State) {
    if (!this.props.isLatest && prevProps.isLatest && !this.userToggled) {
      this.setState({ collapsed: true });
    }
  }

  handleClickToggle = (event: React.SyntheticEvent) => {
    event.stopPropagation();
    this.userToggled = true;
    this.setState({ collapsed: !this.state.collapsed });
  }

  render() {
    const { failed, message, output, repoName } = this.props.record;

    const hasOutput = output !== "";

    return (
      <div className={cx("record", { "has-output": hasOutput })}>
        <div className="line" onClick={this.handleClickToggle}>
          <div className="gutter">{hasOutput && <span className="icon icon-ellipsis" />}</div>
          <div className={cx("message", { "text-error": failed })}>
            [{repoName}] {message}
          </div>
        </div>
        {hasOutput && (
          <div className={cx("output", { collapsed: this.state.collapsed })}>
            <pre
              dangerouslySetInnerHTML={{
                __html: linkify(this.props.ansiConverter.toHtml(output))
              }}
            />
          </div>
        )}
      </div>
    );
  }
}
