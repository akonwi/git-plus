const { parseDiff } = require("../../lib/utils/repository-utils");

const fileName = "lib/platformio-ide-terminal.coffee";
const diffText = `diff --git a/lib/platformio-ide-terminal.coffee b/lib/platformio-ide-terminal.coffee
index bd76ba8..d2d39e8 100755
--- a/${fileName}
+++ b/${fileName}
@@ -1,6 +1,9 @@
 module.exports =
   statusBar: null

+
+
+
   activate: ->

   deactivate: ->`;

describe("repository utils", () => {
  describe("parseDiff", () => {
    expect(parseDiff(diffText)).toBe([
      {
        oldFile: fileName,
        newFile: fileName,
        hunk: `@@ -1,6 +1,9 @@
 module.exports =
   statusBar: null

+
+
+
   activate: ->

   deactivate: ->`
      }
    ]);
  });
});
