// @flow
import { Disposable } from 'atom'

export type Record = {
  message: string,
  output: string,
  repoName?: string,
  failed?: boolean
}

class ActivityLogger {
  listeners: Set<Function> = new Set()

  record(record: Record) {
    // TODO: see if output-view is visible and create a notification if it won't be
    window.requestIdleCallback(() => this.listeners.forEach(listener => listener(record)))
  }

  onDidRecordActivity(callback: Record => any): Disposable {
    this.listeners.add(callback)
    return new Disposable(() => this.listeners.delete(callback))
  }
}

const logger: ActivityLogger = new ActivityLogger()

export default logger
