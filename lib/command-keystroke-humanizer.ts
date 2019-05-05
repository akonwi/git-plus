import { humanizeKeystroke } from "underscore-plus";

export function humanize(commandId: string) {
  const currentPlatformRegex = new RegExp(`\\.platform\\-${process.platform}([,:#\\s]|$)`);

  let result: string | undefined;

  atom.keymaps.findKeyBindings({ command: commandId }).some(binding => {
    if (!currentPlatformRegex.test(binding.selector)) {
      result = humanizeKeystroke(binding.keystrokes);
      return true;
    }
    return false;
  });

  return result;
}
