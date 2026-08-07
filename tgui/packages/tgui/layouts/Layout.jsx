/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { useEffect, useRef } from 'react';

import { computeBoxClassName, computeBoxProps } from '../components/Box';
import { addScrollableNode, removeScrollableNode } from '../events';

export const Layout = (props) => {
  const { className, theme = 'computer', children, ...rest } = props;
  document.documentElement.className = `theme-${theme}`;
  return (
    <div className={'theme-' + theme}>
      <div
        className={classes(['Layout', className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </div>
  );
};

const LayoutContent = (props) => {
  const { className, scrollable, children, ...rest } = props;
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
    <div
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
        className,
        computeBoxClassName(rest),
      ])}
      ref={node}
      {...computeBoxProps(rest)}
    >
      {children}
    </div>
  );
};

Layout.Content = LayoutContent;
