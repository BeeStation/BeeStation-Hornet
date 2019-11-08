import { classes, pureComponentHooks } from 'common/react';
import { clamp, toFixed } from 'common/math';

export const ProgressBar = props => {
  const {
    value,
    minValue = 0,
    maxValue = 1,
    ranges = {},
    content,
    children,
  } = props;
  let { color } = props;
  const scaledValue = (value - minValue) / (maxValue - minValue);
  const hasContent = content !== undefined || children !== undefined;
  if (!color) {
    // Cycle through ranges in key order to determine progressbar color.
    for (let rangeName of Object.keys(ranges)) {
      const range = ranges[rangeName];
      if (range && value >= range[0] && value <= range[1]) {
        color = rangeName;
        break;
      }
    }
  }
  return (
    <div
      className={classes([
        'ProgressBar',
        color && 'ProgressBar--color--' + color,
      ])}>
      <div
        className="ProgressBar__fill"
        style={{
          'width': (clamp(scaledValue, 0, 1) * 100) + '%',
        }} />
      <div className="ProgressBar__content">
        {hasContent && content}
        {hasContent && children}
        {!hasContent && toFixed(scaledValue * 100) + '%'}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;