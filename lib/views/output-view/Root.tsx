import * as AnsiToHtml from "ansi-to-html";
import { CommandEvent, CompositeDisposable } from "atom";
import cx from "classnames";
import * as linkify from "linkify-urls";
import * as React from "react";
import ActivityLogger from "../../activity-logger";
import { Record } from "../../activity-logger";
import { Entry } from "./Entry";

function reverseMap<T>(array: T[], fn: (item: T, index: number) => any): any[] {
  const result: any[] = [];
  for (let i = array.length - 1; i > -1; i--) {
    result.push(fn(array[i], i));
  }
  return result;
}

interface Props {}
interface State {
  records: Record[];
  latestId: string | null;
}

export class Root extends React.Component<Props, State> {
  state = {
    latestId: null,
    records: [...ActivityLogger.records]
  };
  subscriptions = new CompositeDisposable();
  $root = React.createRef<HTMLDivElement>();
  ansiConverter: { toHtml(stuff: string): string } = new AnsiToHtml();

  componentDidMount() {
    this.subscriptions.add(
      ActivityLogger.onDidRecordActivity(record => {
        this.setState(state => ({ latestId: record.id, records: [...state.records, record] }));
      }),
      atom.commands.add("atom-workspace", "git-plus:copy", {
        hiddenInCommandPalette: true,
        didDispatch: (event: CommandEvent) => {
          if (
            event.target &&
            (event.target as HTMLElement).contains(document.querySelector(".git-plus.output"))
          ) {
            atom.clipboard.write(window.getSelection().toString());
          } else event.abortKeyBinding();
        }
      })
    );
    atom.keymaps.add("git-plus", {
      ".platform-darwin atom-workspace": {
        "cmd-c": "git-plus:copy"
      },
      ".platform-win32 atom-workspace, .platform-linux atom-workspace": {
        "ctrl-c": "git-plus:copy"
      }
    });
  }

  componentDidUpdate(previousProps: Props, previousState: State) {
    if (previousState.records.length < this.state.records.length) {
      if (this.$root.current) this.$root.current.scrollTop = 0;
    }
  }

  componentWillUnmount() {
    this.subscriptions.dispose();
    atom.keymaps["removeBindingsFromSource"]("git-plus");
  }

  render() {
    return (
      <div id="root" ref={this.$root}>
        {reverseMap(this.state.records, (record: Record) => (
          <Entry
            isLatest={this.state.latestId === record.id}
            key={record.id}
            record={record}
            ansiConverter={this.ansiConverter}
          />
        ))}
      </div>
    );
  }
}
