/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { forwardRef, ReactNode, RefObject, UIEventHandler, useRef } from 'react';

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type Props = Partial<{
  buttons: ReactNode;
  fill: boolean;
  fitted: boolean;
  independent: boolean;
  scrollable: boolean;
  scrollableHorizontal: boolean;
  title: ReactNode;
  /** @member Allows external control of scrolling. */
  scrollableRef: RefObject<HTMLDivElement>;
  /** @member Callback function for the `scroll` event */
  onScroll: UIEventHandler<HTMLDivElement>;
}> &
  BoxProps;

export const Section = forwardRef((props: Props, forwardedRef: RefObject<HTMLDivElement>) => {
  const {
    className,
    title,
    buttons,
    fill,
    fitted,
    independent,
    scrollable,
    scrollableHorizontal,
    children,
    onScroll,
    ...rest
  } = props;

  const contentRef = useRef<HTMLDivElement>(null);

  const hasTitle = canRender(title) || canRender(buttons);

  const handleMouseEnter = () => {
    if (!scrollable || !contentRef.current) return;

    contentRef.current.focus();
  };

  return (
    <div
      className={classes([
        'Section',
        fill && 'Section--fill',
        fitted && 'Section--fitted',
        independent && 'Sectioned--independent',
        scrollable && 'Section--scrollable',
        scrollableHorizontal && 'Section--scrollableHorizontal',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
      ref={forwardedRef}>
      {hasTitle && (
        <div className="Section__title">
          <span className="Section__titleText">{title}</span>
          <div className="Section__buttons">{buttons}</div>
        </div>
      )}
      <div className="Section__rest">
        <div className="Section__content" onMouseEnter={handleMouseEnter} onScroll={onScroll} ref={contentRef}>
          {children}
        </div>
      </div>
    </div>
  );
});
