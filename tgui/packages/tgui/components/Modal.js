/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Dimmer } from './Dimmer';

export const Modal = props => {
  const {
    className,
    children,
    fitted,
    ...rest
  } = props;
  return (
    <Dimmer>
      <div
        className={classes([
          'Modal',
          fitted && 'Modal--fitted',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {children}
      </div>
    </Dimmer>
  );
};
