import { classes, pureComponentHooks } from 'common/react';
import { tridentVersion } from '../byond';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from '../hotkeys';
import { createLogger } from '../logging';
import { refocusLayout } from '../refocus';
import { Box } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

const logger = createLogger('Button');

export const Button = props => {
  const {
    className,
    fluid,
    icon,
    color,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    content,
    children,
    onclick,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn("Lowercase 'onclick' is not supported on Button and "
      + "lowercase prop names are discouraged in general. "
      + "Please use a camelCase 'onClick' instead and read: "
      + "https://infernojs.org/docs/guides/event-handling");
  }
  // IE8: Use a lowercase "onclick" because synthetic events are fucked.
  // IE8: Use an "unselectable" prop because "user-select" doesn't work.
  return (
    <Box as="span"
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        (color && typeof color === 'string')
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
      ])}
      tabIndex={!disabled && '0'}
      unselectable={tridentVersion <= 4}
      onclick={e => {
        refocusLayout();
        if (!disabled && onClick) {
          onClick(e);
        }
      }}
      onKeyDown={e => {
        const keyCode = window.event ? e.which : e.keyCode;
        // Simulate a click when pressing space or enter.
        if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (keyCode === KEY_ESCAPE) {
          e.preventDefault();
          refocusLayout();
          return;
        }
      }}
      {...rest}>
      {icon && (
        <Icon name={icon} />
      )}
      {content}
      {children}
      {tooltip && (
        <Tooltip
          content={tooltip}
          position={tooltipPosition} />
      )}
    </Box>
  );
};

Button.defaultHooks = pureComponentHooks;

export const ButtonCheckbox = props => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest} />
  );
};

Button.Checkbox = ButtonCheckbox;
