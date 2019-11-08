import { classes, pureComponentHooks, isFalsy } from 'common/react';
import { createVNode } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';

const UNIT_PX = 6;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = value => {
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'number') {
    return (value * UNIT_PX) + 'px';
  }
};

const isColorCode = str => typeof str === 'string' && (
  str.startsWith('#') || str.startsWith('rgb')
);

const mapRawPropTo = attrName => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = value;
  }
};

const mapUnitPropTo = attrName => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = unit(value);
  }
};

const mapBooleanPropTo = (attrName, attrValue) => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = attrValue;
  }
};

const mapDirectionalUnitPropTo = (attrName, dirs) => (style, value) => {
  if (!isFalsy(value)) {
    for (let i = 0; i < dirs.length; i++) {
      style[attrName + '-' + dirs[i]] = unit(value);
    }
  }
};

const mapColorPropTo = attrName => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

const styleMapperByPropName = {
  // Direct mapping
  position: mapRawPropTo('position'),
  width: mapUnitPropTo('width'),
  minWidth: mapUnitPropTo('min-width'),
  maxWidth: mapUnitPropTo('max-width'),
  height: mapUnitPropTo('height'),
  minHeight: mapUnitPropTo('min-height'),
  maxHeight: mapUnitPropTo('max-height'),
  fontSize: mapUnitPropTo('font-size'),
  lineHeight: mapUnitPropTo('line-height'),
  opacity: mapRawPropTo('opacity'),
  textAlign: mapRawPropTo('text-align'),
  // Boolean props
  inline: mapBooleanPropTo('display', 'inline-block'),
  bold: mapBooleanPropTo('font-weight', 'bold'),
  italic: mapBooleanPropTo('font-style', 'italic'),
  // Margins
  m: mapDirectionalUnitPropTo('margin', ['top', 'bottom', 'left', 'right']),
  mx: mapDirectionalUnitPropTo('margin', ['left', 'right']),
  my: mapDirectionalUnitPropTo('margin', ['top', 'bottom']),
  mt: mapUnitPropTo('margin-top'),
  mb: mapUnitPropTo('margin-bottom'),
  ml: mapUnitPropTo('margin-left'),
  mr: mapUnitPropTo('margin-right'),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('background-color'),
};

export const computeBoxProps = props => {
  const computedProps = {};
  const computedStyles = {};
  // Compute props
  for (let propName of Object.keys(props)) {
    if (propName === 'style') {
      continue;
    }
    const propValue = props[propName];
    const mapPropToStyle = styleMapperByPropName[propName];
    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    }
    else {
      computedProps[propName] = propValue;
    }
  }
  // Concatenate styles
  Object.assign(computedStyles, props.style);
  let style = '';
  for (let attrName of Object.keys(computedStyles)) {
    const attrValue = computedStyles[attrName];
    style += attrName + ':' + attrValue + ';';
  }
  if (style.length > 0) {
    computedProps.style = style;
  }
  return computedProps;
};

export const Box = props => {
  const {
    as = 'div',
    className,
    content,
    children,
    ...rest
  } = props;
  const color = props.textColor || props.color;
  // Render props
  if (typeof children === 'function') {
    return children(computeBoxProps(props));
  }
  const computedProps = computeBoxProps(rest);
  // Render a wrapper element
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    classes([
      className,
      color && !isColorCode(color) && 'color-' + color,
    ]),
    content || children,
    ChildFlags.UnknownChildren,
    computedProps);
};

Box.defaultHooks = pureComponentHooks;
