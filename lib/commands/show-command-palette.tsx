/** @jsx etch.dom */
import { Panel } from "atom";
import SelectList = require("atom-select-list");
import etch = require("etch");
import memoizeOne = require("memoize-one");
import { humanizeEventName } from "underscore-plus";
import { getRepoCommands } from ".";
import { humanize } from "../command-keystroke-humanizer";
import { RepositoryCommand } from "./common";

const getCommandsWithDisplayNames = memoizeOne((commands: RepositoryCommand<any>[]) =>
  commands.map(command => ({
    ...command,
    displayName: command.displayName || (humanizeEventName(command.id) as string)
  }))
);

export function showCommandPalette() {
  const previouslyFocusedElement = document.activeElement as HTMLElement | null;
  let panel: Panel;

  const listView = new SelectList({
    items: getCommandsWithDisplayNames(getRepoCommands()),
    emptyMessage: "No commands matching query",
    filterKeyForItem: command => command.displayName,
    elementForItem: command => (new CommandView({ command }) as any).element,
    didCancelSelection: () => {
      previouslyFocusedElement && previouslyFocusedElement.focus();
      panel && panel.destroy();
    },
    didConfirmSelection: command => {
      atom.commands.dispatch(atom.views.getView(atom.workspace), `git-plus:${command.id}`);
      previouslyFocusedElement && previouslyFocusedElement.focus();
      panel && panel.destroy();
    }
  });
  panel = atom.workspace.addModalPanel({ item: listView.element });
  panel.onDidDestroy(() => {
    listView.destroy();
  });
  listView.focus();
}

interface Props {
  command: RepositoryCommand<any>;
}

class CommandView {
  constructor(private readonly props: Props) {
    etch.initialize(this);
  }

  update(props, children) {
    return etch.update(this);
  }

  render() {
    const { command } = this.props;
    const keystroke = humanize(`git-plus:${command.id}`);

    return (
      <li className="command" data-command-name={command.id}>
        <span>{command.displayName}</span>
        {keystroke ? (
          <div className="pull-right">
            <kbd className="key-binding">{keystroke}</kbd>
          </div>
        ) : (
          ""
        )}
      </li>
    );
  }
}
