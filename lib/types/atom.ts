import { TextEditor } from "atom";

declare module "atom" {
  interface TextEditor {
    getElement(): HTMLElement;
    destroy(): void;
  }
}
