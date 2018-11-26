// @flow
import { CompositeDisposable } from 'atom'
import * as React from 'react'
import cx from 'classnames'
import AnsiToHtml from 'ansi-to-html'
import linkify from 'linkify-urls'
import ActivityLogger from '../../activity-logger'
import OutputViewContainer from './container'
import type { Record } from '../../activity-logger'

function reverseMap(array, fn) {
  const result = []
  for (let i = array.length - 1; i > -1; i--) {
    result.push(fn(array[i], i))
  }
  return result
}

class Entry extends React.Component<Record, { collapsed: boolean }> {
  state = {
    collapsed:
      atom.config.get('git-plus.general.alwaysOpenDockWithResult') && this.props.isLatest
        ? false
        : true
  }
  ansiConverter: { toHtml: string => string } = new AnsiToHtml()

  handleClickToggle = (event: SyntheticEvent<>) => {
    event.stopPropagation()
    this.setState({ collapsed: !this.state.collapsed })
  }

  render() {
    const { failed, message, output, repoName } = this.props

    const hasOutput = output !== ''

    return (
      <div className={cx('record', { 'has-output': hasOutput })}>
        <div className="line" onClick={this.handleClickToggle}>
          <div className="gutter">{hasOutput && <span className="icon icon-ellipsis" />}</div>
          <div className={cx('message', { 'text-error': failed })}>
            [{repoName}] {message}
          </div>
        </div>
        {hasOutput && (
          <div className={cx('output', { collapsed: this.state.collapsed })}>
            <pre
              dangerouslySetInnerHTML={{
                __html: linkify(this.ansiConverter.toHtml(output))
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
    latestId: null,
    records: []
  }
  subscriptions = new CompositeDisposable()
  $root = React.createRef()

  componentDidMount() {
    this.subscriptions.add(
      ActivityLogger.onDidRecordActivity(record => {
        this.setState(state => ({ latestId: record.id, records: [...state.records, record] }))
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
        {reverseMap(this.state.records, record => (
          <Entry isLatest={this.state.latestId === record.id} key={record.id} {...record} />
        ))}
      </div>
    )
  }
}
