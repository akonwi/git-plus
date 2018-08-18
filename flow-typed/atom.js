// @flow
declare module 'atom' {
  declare export class Disposable {
    constructor(disposalAction: () => any): Disposable;
    dispose(): void;
    static isDisposable(object: any): boolean;
  }

  declare export class CompositeDisposable {
    constructor(...disposables?: Disposable[]): CompositeDisposable;
    add(...disposables: Disposable[]): void;
    remove(disposable: Disposable): void;
    clear(): void;
    dispose(): void;
  }

  declare class TextBuffer {
    onDidReload(callback: Function): Disposable;
  }

  declare export class TextEditor {
    id: number;
    getBuffer(): TextBuffer;
    onDidChangeModified(callback: (isModified: boolean) => any): Disposable;
    onDidStopChanging(callback: Function): Disposable;
    onDidDestroy(callback: Function): Disposable;
    getPath(): string;
  }

  declare export class GitRepository {
    static open(path: string, options?: { refreshOnWindowFocus: boolean }): GitRepository | null;
    getWorkingDirectory(): string;
    destroy(): void;
    isDestroyed(): boolean;
    relativize(path: string): string;
    isStatusModified(number): boolean;
    isPathModified(string): boolean;
    onDidChangeStatus((event: { path: string, pathStatus: number }) => any): Disposable;
  }

  declare export class Directory {
    constructor(path: string, symlink?: boolean): Directory;
    getPath(): string;
    contains(path: string): boolean;
  }

  declare export class File {
    constructor(path: string, symlink?: boolean): File;
    getParent(): Directory;
  }

  declare type PointArray = [number, number]

  declare type PointThing = Point | PointArray

  declare export class Point {
    row: number;
    column: number;
    constructor(row: number, column: number): Point;
  }

  declare export class Range {
    start: Point;
    end: Point;
    constructor(a: PointThing, b: PointThing): Range;
  }

  declare type ProcessOptions = {
    command: string,
    args?: string[],
    options?: {},
    stdout?: (data: string) => any,
    stderr?: (data: string) => any,
    exit?: (code: number) => any,
    autoStart?: boolean
  }

  declare type ProcessError = {
    error: {},
    handle(): void
  }

  declare export class BufferedProcess {
    constructor(ProcessOptions): BufferedProcess;
    onWillThrowError(callback: (error: ProcessError) => any): Disposable;
    kill(): void;
    start(): void;
  }
}
