// @flow
import { CompositeDisposable } from 'atom'
import * as React from 'react'
import cx from 'classnames'
import AnsiToHtml from 'ansi-to-html'
import ActivityLogger from '../../activity-logger'
import OutputViewContainer from './output-view-container'
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

type RootProps = {
  container: OutputViewContainer
}
type RootState = { records: Record[] }

export default class Root extends React.Component<RootProps, RootState> {
  state = {
    records: []
  }
  subscriptions = new CompositeDisposable()
  $root = React.createRef()

  componentDidMount() {
    this.subscriptions.add(
      ActivityLogger.onDidRecordActivity(record => {
        this.setState(state => ({ records: [...state.records, record] }))
      }),
      atom.commands.add('atom-workspace', 'git-plus:copy', {
        hiddenInCommandPalette: true,
        didDispatch: event => {
          if (event.target.contains(document.querySelector('.git-plus.output')))
            atom.clipboard.write(window.getSelection().toString())
          else event.abortKeyBinding()
        }
      })
    )
    atom.keymaps.add('git-plus', {
      '.platform-darwin atom-workspace': {
        'cmd-c': 'git-plus:copy'
      },
      '.platform-win32 atom-workspace, .platform-linux atom-workspace': {
        'ctrl-c': 'git-plus:copy'
      }
    })
  }

  componentDidUpdate(previousProps: RootProps, previousState: RootState) {
    if (previousState.records.length < this.state.records.length) {
      if (atom.config.get('git-plus.general.alwaysOpenDockWithResult')) this.props.container.show()
      if (this.$root.current) this.$root.current.scrollTop = 1000000
    }
  }

  componentWillUnmount() {
    this.subscriptions.dispose()
    atom.keymaps.removeBindingsFromSource('git-plus')
  }

  render() {
    return (
      <div id="root" ref={this.$root}>
        {this.state.records.map((record, i) => <Entry key={i} {...record} />)}
      </div>
    )
  }
}
