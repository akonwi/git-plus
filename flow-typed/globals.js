// @flow
import { Directory, Disposable, GitRepository, TextEditor } from 'atom'

type CommandListenerFunction = (event: any) => void
type CommandListenerDescriptor = {
  didDispatch: CommandListenerFunction,
  description?: string,
  displayName?: string,
  hiddenInCommandPalette?: boolean
}
type CommandListener = CommandListenerFunction | CommandListenerDescriptor
type CommandListeners = {
  [name: string]: CommandListenerFunction
}

type Atom = {
  commands: {
    add(target: string, commandName: string, listener: CommandListener): Disposable,
    add(target: string, commands: CommandListeners): Disposable
  },
  project: {
    repositoryForDirectory(Directory): Promise<GitRepository>
  },
  workspace: {
    getTextEditors(): TextEditor[],
    observeActiveTextEditor(callback: (editor: TextEditor | void) => any): Disposable
  }
}

declare var atom: Atom
