// @flow
import { Disposable } from 'atom'

// taken from: https://gist.github.com/jed/982883
const makeId = a =>
  a
    ? (a ^ ((Math.random() * 16) >> (a / 4))).toString(16)
    : ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, makeId)

export type Record = {
  message: string,
  output: string,
  repoName: string,
  id: string,
  failed?: boolean
}

class ActivityLogger {
  listeners: Set<Function> = new Set()

  record(record: Record) {
    // TODO: see if output-view is visible and create a notification if it won't be
    window.requestIdleCallback(() =>
      this.listeners.forEach(listener => listener({ ...record, id: makeId() }))
    )
  }

  onDidRecordActivity(callback: Record => any): Disposable {
    this.listeners.add(callback)
    return new Disposable(() => this.listeners.delete(callback))
  }
}

const logger: ActivityLogger = new ActivityLogger()

export default logger
