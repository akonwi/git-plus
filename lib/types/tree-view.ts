export interface TreeView {
  selectedPaths(): string[];
  entryForPath(entryPath: string): any;
}
