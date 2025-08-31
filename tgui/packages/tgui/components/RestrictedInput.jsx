import { isEscape, KEY } from 'common/keys';
import { clamp } from 'common/math';
import { classes } from 'common/react';
import { React, useEffect, useRef, useState } from 'react';

import { Box } from './Box';

const DEFAULT_MIN = 0;
const DEFAULT_MAX = 10000;

/**
 * Takes a string input and parses integers or floats from it.
 * If none: Minimum is set.
 * Else: Clamps it to the given range.
 */
const getClampedNumber = (value, minValue, maxValue, allowFloats) => {
  const minimum = minValue || DEFAULT_MIN;
  const maximum = maxValue || maxValue === 0 ? maxValue : DEFAULT_MAX;
  if (!value || !value.length) {
    return String(minimum);
  }
  let parsedValue = allowFloats
    ? parseFloat(value.replace(/[^\-\d.]/g, ''))
    : parseInt(value.replace(/[^\-\d]/g, ''), 10);
  if (isNaN(parsedValue)) {
    return String(minimum);
  } else {
    return String(clamp(parsedValue, minimum, maximum));
  }
};

export const RestrictedInput = (props) => {
  const {
    value,
    onChange,
    onInput,
    onEnter,
    onEscape,
    minValue,
    maxValue,
    allowFloats,
    autoFocus,
    autoSelect,
    className,
    fluid,
    monospace,
    ...boxProps
  } = props;

  const inputRef = useRef(null);
  const [editing, setEditing] = useState(false);

  const handleBlur = () => {
    if (editing) {
      setEditing(false);
    }
    const input = inputRef.current;
    if (input) {
      input.value = getClampedNumber(
        value?.toString(),
        minValue,
        maxValue,
        allowFloats,
      );
    }
  };

  const handleChange = (e) => {
    if (onChange) {
      onChange(e, +e.target.value);
    }
  };

  const handleFocus = () => {
    if (!editing) {
      setEditing(true);
    }
  };

  const handleInput = (e) => {
    if (!editing) {
      setEditing(true);
    }
    if (onInput) {
      onInput(e, +e.target.value);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === KEY.Enter) {
      const safeNum = getClampedNumber(
        e.target.value,
        minValue,
        maxValue,
        allowFloats,
      );
      e.target.value = safeNum;
      setEditing(false);
      if (onChange) {
        onChange(e, +safeNum);
      }
      if (onEnter) {
        onEnter(e, +safeNum);
      }
      e.target.blur();
      return;
    }
    if (isEscape(e.key)) {
      if (onEscape) {
        onEscape(e);
        return;
      }
      setEditing(false);
      e.target.value = value;
      e.target.blur();
      return;
    }

    let restricted_characters = allowFloats ? /[^\d.-]/g : /[^\d-]/g;
    let allowed_keys = [
      KEY.Backspace,
      KEY.Delete,
      KEY.ArrowLeft,
      KEY.ArrowRight,
      KEY.Tab,
      KEY.Enter,
      KEY.Escape,
    ];
    if (
      !allowed_keys.includes(e.key) &&
      e.key.length === 1 &&
      restricted_characters.test(e.key)
    ) {
      e.preventDefault();
      return;
    }
  };

  useEffect(() => {
    const input = inputRef.current;
    if (input && !editing) {
      input.value = getClampedNumber(
        value?.toString(),
        minValue,
        maxValue,
        allowFloats,
      );
    }
  }, [value, minValue, maxValue, allowFloats, editing]);

  // Effect for setting the input value
  useEffect(() => {
    const input = inputRef.current;
    if (input) {
      input.value = value;
    }
  }, [inputRef]);

  // Effect for handling focus
  useEffect(() => {
    if (autoFocus) {
      const input = inputRef.current;
      if (input) {
        input.focus();
      }
    }
  }, [autoFocus]);

  // Effect for handling selection
  useEffect(() => {
    if (autoSelect) {
      const input = inputRef.current;
      if (input) {
        input.select();
      }
    }
  }, [autoSelect]);

  return (
    <Box
      className={classes([
        'Input',
        fluid && 'Input--fluid',
        monospace && 'Input--monospace',
        className,
      ])}
      {...boxProps}
    >
      <div className="Input__baseline">.</div>
      <input
        className="Input__input"
        onChange={handleChange}
        onInput={handleInput}
        onFocus={handleFocus}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        ref={inputRef}
        type="number"
      />
    </Box>
  );
};
