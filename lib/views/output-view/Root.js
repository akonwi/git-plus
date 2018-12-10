// @flow
import { CompositeDisposable } from 'atom'
import * as React from 'react'
import cx from 'classnames'
import AnsiToHtml from 'ansi-to-html'
import linkify from 'linkify-urls'
import ActivityLogger from '../../activity-logger'
import OutputViewContainer from './container'
import { Entry } from './Entry'
import type { Record } from '../../activity-logger'

function reverseMap(array, fn) {
  const result = []
  for (let i = array.length - 1; i > -1; i--) {
    result.push(fn(array[i], i))
  }
  return result
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
  ansiConverter: { toHtml: (stuff: string) => string } = new AnsiToHtml()

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
      if (this.$root.current) this.$root.current.scrollTop = 0
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
          <Entry
            isLatest={this.state.latestId === record.id}
            key={record.id}
            record={record}
            ansiConverter={this.ansiConverter}
          />
        ))}
      </div>
    )
  }
}
