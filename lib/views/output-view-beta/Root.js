// @flow
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
    return (
      <li className={cx('list-nested-item', { collapsed: this.state.collapsed })}>
        <div className="list-item" onClick={this.handleClickToggle}>
          {this.props.record.command}
        </div>
        <ul className="list-tree has-flat-children">
          <li className="list-item">
            <pre
              dangerouslySetInnerHTML={{
                __html: this.ansiConverter.toHtml(this.props.record.result)
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

  componentDidMount() {
    ActivityLogger.onDidRecordActivity(record => {
      this.setState(state => ({ records: [...state.records, record] }))
    })
  }

  render() {
    return (
      <div className="root">
        <ul className="list-tree has-collapsable-children">
          {this.state.records.map((record, i) => <Entry key={i} record={record} />)}
        </ul>
      </div>
    )
  }
}
