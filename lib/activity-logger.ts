import { Disposable } from "atom";
import { viewController } from "./views/controller";
import { OutputViewContainer } from "./views/output-view/container";

// taken from: https://gist.github.com/jed/982883
const makeId: (...args: any[]) => string = a =>
  a
    ? (a ^ ((Math.random() * 16) >> (a / 4))).toString(16)
    : ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, makeId);

interface RecordAttributes {
  message: string;
  output: string;
  repoName: string;
  failed?: boolean;
}
export interface Record extends RecordAttributes {
  id: string;
}

class ActivityLogger {
  listeners: Set<Function> = new Set();
  private _records: Record[] = [];

  get records() {
    return this._records;
  }

  record(attributes: RecordAttributes) {
    const record = { ...attributes, id: makeId() };

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

const logger: ActivityLogger = new ActivityLogger();

export default logger;

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
