import { Disposable } from "atom";
import nanoid = require("nanoid");
import { viewController } from "./views/controller";
import { OutputViewContainer } from "./views/output-view/container";

export interface RecordAttributes {
  message: string;
  output: string;
  repoName: string;
  failed?: boolean;
}
export interface Record extends RecordAttributes {
  id: string;
}

export class ActivityLogger {
  listeners: Set<Function> = new Set();
  private _records: Record[] = [];

  get records() {
    return this._records;
  }

  record(attributes: RecordAttributes) {
    const record = { ...attributes, id: nanoid() };

    if (
      record.failed &&
      !atom.config.get("git-plus.general.alwaysOpenDockWithResult") &&
      !viewController.isVisible(OutputViewContainer.URI)
    ) {
      atom.notifications.addError(`Unable to complete command: ${record.message}`, {
        detail: record.output,
        buttons: [
          {
            text: "Open Output View",
            onDidClick: () => {
              atom.commands.dispatch(
                document.querySelector("atom-workspace")!,
                "git-plus:toggle-output-view"
              );
            }
          }
        ]
      });
    }

    this._records.push(record);
    window.requestIdleCallback(() => {
      this.listeners.forEach(listener => listener(record));
      if (atom.config.get("git-plus.general.alwaysOpenDockWithResult")) {
        viewController.getOutputView().show();
      }
    });
  }

  onDidRecordActivity(callback: (record: Record) => any): Disposable {
    this.listeners.add(callback);
    return new Disposable(() => this.listeners.delete(callback));
  }
}

type RequestIdleCallbackHandle = any;
interface RequestIdleCallbackOptions {
  timeout: number;
}
interface RequestIdleCallbackDeadline {
  readonly didTimeout: boolean;
  timeRemaining: (() => number);
}

declare global {
  interface Window {
    requestIdleCallback: ((
      callback: ((deadline: RequestIdleCallbackDeadline) => void),
      opts?: RequestIdleCallbackOptions
    ) => RequestIdleCallbackHandle);
    cancelIdleCallback: ((handle: RequestIdleCallbackHandle) => void);
  }
}
