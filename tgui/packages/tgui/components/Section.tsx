/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { Component, createRef, RefObject } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import type { InfernoNode } from 'inferno';

interface SectionProps extends BoxProps {
  className?: string;
  title?: string;
  buttons?: InfernoNode;
  fill?: boolean;
  fitted?: boolean;
  scrollable?: boolean;
  /** @deprecated This property no longer works, please remove it. */
  level?: boolean;
  /** @deprecated Please use `scrollable` property */
  overflowY?: any;
  /** @member Allows external control of scrolling. */
  scrollableRef?: RefObject<HTMLDivElement>;
  /** @member Callback function for the `scroll` event */
  onScroll?: (this: GlobalEventHandlers, ev: Event) => any;
}

export class Section extends Component<SectionProps> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;
  onScroll?: (this: GlobalEventHandlers, ev: Event) => any;

  constructor(props) {
    super(props);
    this.scrollableRef = props.scrollableRef || createRef();
    this.scrollable = props.scrollable;
    this.onScroll = props.onScroll;
  }

  componentDidMount() {
    if (this.scrollable) {
      addScrollableNode(this.scrollableRef.current);
      if (this.onScroll && this.scrollableRef.current) {
        this.scrollableRef.current.onscroll = this.onScroll;
      }
    }
  }

  componentWillUnmount() {
    if (this.scrollable) {
      removeScrollableNode(this.scrollableRef.current);
    }
  }

  render() {
    const { className, title, buttons, fill, fitted, independent, scrollable, children, ...rest } = this.props;
    const hasTitle = canRender(title) || canRender(buttons);
    return (
      <div
        className={classes([
          'Section',
          Byond.IS_LTE_IE8 && 'Section--iefix',
          fill && 'Section--fill',
          fitted && 'Section--fitted',
          scrollable && 'Section--scrollable',
          independent && 'Section--independent',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {hasTitle && (
          <div className="Section__title">
            <span className="Section__titleText">{title}</span>
            <div className="Section__buttons">{buttons}</div>
          </div>
        )}
        <div className="Section__rest">
          <div ref={this.scrollableRef} className="Section__content">
            {children}
          </div>
        </div>
      </div>
    );
  }
}
