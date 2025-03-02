/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { isEscape, KEY } from 'common/keys';
import { classes } from 'common/react';
import { Component, createRef } from 'react';
import { Box, computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

export const Button = (props) => {
  const {
    className,
    fluid,
    icon,
    iconRotation,
    iconSpin,
    iconColor,
    iconPosition,
    color,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    compact,
    circular,
    content,
    children,
    onClick,
    verticalAlignContent,
    captureKeys,
    ...rest
  } = props;
  const hasContent = !!(content || children);

  rest.onClick = (e) => {
    if (!disabled && onClick) {
      onClick(e);
    }
  };

  let buttonContent = (
    <div
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        circular && 'Button--circular',
        compact && 'Button--compact',
        iconPosition && 'Button--iconPosition--' + iconPosition,
        verticalAlignContent && 'Button--flex',
        verticalAlignContent && fluid && 'Button--flex--fluid',
        verticalAlignContent && 'Button--verticalAlignContent--' + verticalAlignContent,
        color && typeof color === 'string' ? 'Button--color--' + color : 'Button--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled && '0'}
      onKeyDown={(e) => {
        if (captureKeys === false) {
          return;
        }

        // Simulate a click when pressing space or enter.
        if (e.key === KEY.Space || e.key === KEY.Enter) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (isEscape(e.key)) {
          e.preventDefault();
          return;
        }
      }}
      {...computeBoxProps(rest)}>
      <div className="Button__content">
        {icon && iconPosition !== 'right' && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
        {content}
        {children}
        {icon && iconPosition === 'right' && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
      </div>
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
};

export const ButtonCheckbox = (props) => {
  const { checked, ...rest } = props;
  return <Button color="transparent" icon={checked ? 'check-square-o' : 'square-o'} selected={checked} {...rest} />;
};

Button.Checkbox = ButtonCheckbox;

export class ButtonConfirm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      clickedOnce: false,
    };
    this.handleClick = () => {
      if (this.state.clickedOnce) {
        this.setClickedOnce(false);
      }
    };
  }

  setClickedOnce(clickedOnce) {
    this.setState({
      clickedOnce,
    });
    if (clickedOnce) {
      setTimeout(() => window.addEventListener('click', this.handleClick));
    } else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  render() {
    const {
      confirmContent = 'Confirm?',
      confirmColor = 'bad',
      confirmIcon,
      icon,
      color,
      content,
      onClick,
      ...rest
    } = this.props;
    return (
      <Button
        content={this.state.clickedOnce ? confirmContent : content}
        icon={this.state.clickedOnce ? confirmIcon : icon}
        color={this.state.clickedOnce ? confirmColor : color}
        onClick={() => (this.state.clickedOnce ? onClick() : this.setClickedOnce(true))}
        {...rest}
      />
    );
  }
}

Button.Confirm = ButtonConfirm;

export class ButtonInput extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      inInput: false,
    };
  }

  setInInput(inInput) {
    this.setState({
      inInput,
    });
    if (this.inputRef) {
      const input = this.inputRef.current;
      if (inInput) {
        input.value = this.props.currentValue || '';
        try {
          input.focus();
          input.select();
        } catch {}
      }
    }
  }

  commitResult(e) {
    if (this.inputRef) {
      const input = this.inputRef.current;
      const hasValue = input.value !== '';
      if (hasValue) {
        this.props.onCommit(e, input.value);
        return;
      } else {
        if (!this.props.defaultValue) {
          return;
        }
        this.props.onCommit(e, this.props.defaultValue);
      }
    }
  }

  render() {
    const {
      fluid,
      content,
      icon,
      iconRotation,
      iconSpin,
      tooltip,
      tooltipPosition,
      color = 'default',
      placeholder,
      maxLength,
      ...rest
    } = this.props;

    let buttonContent = (
      <Box
        className={classes(['Button', fluid && 'Button--fluid', 'Button--color--' + color])}
        {...rest}
        onClick={() => this.setInInput(true)}>
        {icon && <Icon name={icon} color={iconColor} rotation={iconRotation} spin={iconSpin} />}
        <div>{content}</div>
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            display: !this.state.inInput ? 'none' : '',
            textAlign: 'left',
          }}
          onBlur={(e) => {
            if (!this.state.inInput) {
              return;
            }
            this.setInInput(false);
            this.commitResult(e);
          }}
          onKeyDown={(e) => {
            if (e.key === KEY.Enter) {
              this.setInInput(false);
              this.commitResult(e);
              return;
            }
            if (isEscape(e.key)) {
              this.setInInput(false);
            }
          }}
        />
      </Box>
    );

    if (tooltip) {
      buttonContent = (
        <Tooltip content={tooltip} position={tooltipPosition}>
          {buttonContent}
        </Tooltip>
      );
    }

    return buttonContent;
  }
}

Button.Input = ButtonInput;
