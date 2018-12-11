declare module "atom-select-list" {
  interface Options<T> {
    items: T[];
    elementForItem(
      item: T,
      options: { selected: boolean; index: number; visible: boolean }
    ): HTMLElement;
    maxResults?: number;
    filter?(items: T[], query: string): T[];
    filterKeyForItem?(item: T): string;
    filterQuery?(query: string): string;
    query?(): string;
    selectQuery?(): boolean;
    order?(item1: T, item2: T): number;
    emptyMessage?: string;
    errorMessage?: string;
    infoMessage?: string;
    loadingMessage?: string;
    loadingBadge?: string | number;
    itemsClassList?: string[];
    initialSelectionIndex?: number;
    didChangeQuery?(): void;
    didChangeSelection?(item: T): void;
    didConfirmSelection?(item: T): void;
    didConfirmEmptySelection?(): void;
    didCancelSelection?(): void;
    initiallyVisibleItemCount?(): number;
  }

  class SelectList<T> {
    constructor(options: Options<T>);
    element: HTMLElement;
    destroy(): void;
    focus(): void;
  }
  export = SelectList;
}
