import * as etch from "etch";
import { configs } from "./config";
import { GitPlusPackage } from "./package";

let gitPlus;
const packageWrapper = {
  config: configs,
  initialize(_state) {
    etch.setScheduler(atom.views);
    gitPlus = new GitPlusPackage();
  }
};

export = new Proxy(packageWrapper, {
  get(target, name) {
    if (gitPlus && Reflect.has(gitPlus, name)) {
      let property = gitPlus[name];
      if (typeof property === "function") {
        property = property.bind(gitPlus);
      }
      return property;
    } else {
      return target[name];
    }
  }
});
