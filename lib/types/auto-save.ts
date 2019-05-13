interface PaneItem {
  getPath(): string;
}

export interface AutoSave {
  dontSaveIf(test: (item: PaneItem) => boolean): void;
}
