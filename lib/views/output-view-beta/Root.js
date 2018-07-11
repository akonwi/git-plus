// @flow
import * as React from 'react'
import cx from 'classnames'
import ActivityLogger from '../../activity-logger'
import type { Record } from '../../activity-logger'

type State = {
  records: Record[]
}

class Entry extends React.Component<{ record: Record }, { collapsed: boolean }> {
  state = {
    collapsed: true
  }

  render() {
    return (
      <li
        className={cx('list-nested-item', { collapsed: this.state.collapsed })}
        onClick={e => this.setState({ collapsed: !this.state.collapsed })}
      >
        <div className="list-item">{this.props.record.command}</div>
        <ul className="list-tree has-flat-children">
          <li className="list-item">{this.props.record.result}</li>
        </ul>
      </li>
    )
  }
}

export default class Root extends React.Component<{}, State> {
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
