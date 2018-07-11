import { Disposable } from 'atom'

// @flow
export type Record = {
  command: string,
  result: string
}

class ActivityLogger {
  listeners: Set<Function> = new Set()

  record(record: Record) {
    this.listeners.forEach(listener => listener(record))
  }

  onDidRecordActivity(callback: Record => any): Disposable {
    this.listeners.add(callback)
    return new Disposable(() => this.listeners.delete(callback))
  }
}

const logger = new ActivityLogger()

export default logger
