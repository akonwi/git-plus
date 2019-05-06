import { TextEditor } from "atom";

declare module "atom" {
  interface TextEditor {
    destroy(): void;
  }
}
