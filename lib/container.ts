import { ActivityLogger } from "./activity-logger";
import { ViewController } from "./views/controller";

export class Container {
  static readonly logger = new ActivityLogger();

  static readonly viewController = new ViewController();
}
