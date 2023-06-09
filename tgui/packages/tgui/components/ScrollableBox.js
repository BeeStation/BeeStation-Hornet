import { Box } from './Box';
import { addScrollableNode, removeScrollableNode } from '../events';

export const ScrollableBox = (props) => {
  const { children, ...rest } = props;
  return <Box {...rest}>{children}</Box>;
};

ScrollableBox.defaultHooks = {
  onComponentDidMount: (node) => addScrollableNode(node),
  onComponentWillUnmount: (node) => removeScrollableNode(node),
};
