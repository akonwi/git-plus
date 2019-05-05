export interface Tile {
  getPriority(): number;
  getItem(): any;
  destroy(): void;
}

export interface TileOptions {
  item: any;
  priority: number;
}

export interface StatusBar {
  addLeftTile(options: TileOptions): Tile;
  addRightTile(options: TileOptions): Tile;
}
