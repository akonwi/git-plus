import { Disposable } from "atom";
import * as React from "react";

const CONFIG_KEY = "git-plus";

export interface WithConfigsProps {
  configs: {};
}

export function withConfigs<Props extends WithConfigsProps>(Child: React.ComponentType<Props>) {
  return (props: Props) => (
    <ConfigProvider>
      {(configs: {}) => {
        return <Child {...props} configs={configs} />;
      }}
    </ConfigProvider>
  );
}

const getConfigs = () => atom.config.get(CONFIG_KEY) || {};

interface Props {
  children(configs: {}): React.ReactNode;
}
class ConfigProvider extends React.Component<Props, {}> {
  state = getConfigs();
  disposable?: Disposable;

  componentDidMount() {
    this.disposable = atom.config.onDidChange(CONFIG_KEY, event => {
      this.setState(getConfigs());
    });
  }

  componentWillUnmount() {
    this.disposable && this.disposable.dispose();
  }

  render() {
    return this.props.children({ ...this.state });
  }
}
