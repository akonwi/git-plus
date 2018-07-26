// @flow
import type { Disposable } from 'atom'
import * as React from 'react'
import cx from 'classnames'
import AnsiToHtml from 'ansi-to-html'
import ActivityLogger from '../../activity-logger'
import type { Record } from '../../activity-logger'

class Entry extends React.Component<Record, { collapsed: boolean }> {
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
    const { failed, message, output } = this.props

    const hasOutput = output !== ''

    return (
      <div className={cx('record', { 'has-output': hasOutput })}>
        <div className="line" onClick={this.handleClickToggle}>
          <div className="gutter">{hasOutput && <span className="icon icon-ellipsis" />}</div>
          <div className={cx('message', { 'text-error': failed })}>{message}</div>
        </div>
        {hasOutput && (
          <div className={cx('output', { collapsed: this.state.collapsed })}>
            <pre
              dangerouslySetInnerHTML={{
                __html: this.ansiConverter.toHtml(output)
              }}
            />
          </div>
        )}
      </div>
    )
  }
}

export default class Root extends React.Component<{}, { records: Record[] }> {
  state = {
    records: []
  }
  subscription: Disposable
  $root = React.createRef()

  componentDidMount() {
    this.subscription = ActivityLogger.onDidRecordActivity(record => {
      this.setState(state => ({ records: [...state.records, record] }))
    })
  }

  componentDidUpdate(previousProps, previousState) {
    if (this.$root.current) this.$root.current.scrollTop = 1000000
  }

  componentWillUnmount() {
    this.subscription && this.subscription.dispose()
  }

  render() {
    return (
      <div id="root" ref={this.$root}>
        {this.state.records.map((record, i) => <Entry key={i} {...record} />)}
      </div>
    )
  }
}
