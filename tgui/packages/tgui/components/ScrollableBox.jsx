import { useEffect, useRef } from 'react';
import { addScrollableNode, removeScrollableNode } from 'tgui/events';

import { Box } from './Box';

export const ScrollableBox = (props) => {
  const { children, ...rest } = props;
  const node = useRef(null);
  useEffect(() => {
    const self = node.current;
    if (self && scrollable) {
      addScrollableNode(self);
    }
    return () => {
      if (self && scrollable) {
        removeScrollableNode(self);
      }
    };
  }, []);

  return (
    <Box ref={node} {...rest}>
      {children}
    </Box>
  );
};
