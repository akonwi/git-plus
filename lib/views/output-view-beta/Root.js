// @flow
import type { Disposable } from 'atom'
import * as React from 'react'
import cx from 'classnames'
import AnsiToHtml from 'ansi-to-html'
import ActivityLogger from '../../activity-logger'
import type { Record } from '../../activity-logger'

class Entry extends React.Component<{ record: Record }, { collapsed: boolean }> {
  state = {
    collapsed: true
  }
  ansiConverter: { toHtml: string => string }

  constructor() {
    super()
    this.ansiConverter = new AnsiToHtml()
  }

  handleClickToggle = (event: SyntheticEvent<>) => {
    event.stopPropagation()
    this.setState({ collapsed: !this.state.collapsed })
  }

  render() {
    const { record } = this.props
    if (record.output === '') return <div className="list-item">{record.message}</div>

    return (
      <li className={cx('list-nested-item', { collapsed: this.state.collapsed })}>
        <div className="list-item" onClick={this.handleClickToggle}>
          {record.message}
        </div>
        <ul className="list-tree has-flat-children">
          <li className="list-item">
            <pre
              dangerouslySetInnerHTML={{
                __html: this.ansiConverter.toHtml(record.output)
              }}
            />
          </li>
        </ul>
      </li>
    )
  }
}

export default class Root extends React.Component<{}, { records: Record[] }> {
  state = {
    records: []
  }
  subscription: Disposable

  componentDidMount() {
    this.subscription = ActivityLogger.onDidRecordActivity(record => {
      this.setState(state => ({ records: [...state.records, record] }))
    })
  }

  componentWillUnmount() {
    this.subscription && this.subscription.dispose()
  }

  render() {
    let child
    if (this.state.records.length === 0) child = <h3 id="empty-message">No Git+ activity</h3>
    else
      child = (
        <ul className="list-tree has-collapsable-children">
          {this.state.records.map((record, i) => <Entry key={i} record={record} />)}
        </ul>
      )
    return <div className="root">{child}</div>
  }
}
