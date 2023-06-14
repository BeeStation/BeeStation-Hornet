/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { computeFlexClassName, computeFlexItemClassName, computeFlexItemProps, computeFlexProps, FlexItemProps, FlexProps } from './Flex';

type StackProps = FlexProps & {
  vertical?: boolean;
  fill?: boolean;
};

export const Stack = (props: StackProps) => {
  const { className, vertical, fill, ...rest } = props;
  return (
    <div
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical ? 'Stack--vertical' : 'Stack--horizontal',
        className,
        computeFlexClassName(props),
      ])}
      {...computeFlexProps({
        direction: vertical ? 'column' : 'row',
        ...rest,
      })}
    />
  );
};

const StackItem = (props: FlexProps) => {
  const { className, ...rest } = props;
  return (
    <div className={classes(['Stack__item', className, computeFlexItemClassName(rest)])} {...computeFlexItemProps(rest)} />
  );
};

Stack.Item = StackItem;

type StackDividerProps = FlexItemProps & {
  hidden?: boolean;
};

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;
  return (
    <div
      className={classes([
        'Stack__item',
        'Stack__divider',
        hidden && 'Stack__divider--hidden',
        className,
        computeFlexItemClassName(rest),
      ])}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Divider = StackDivider;
