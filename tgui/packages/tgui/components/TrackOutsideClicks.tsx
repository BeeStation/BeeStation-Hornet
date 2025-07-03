import { Component, createRef, PropsWithChildren } from 'react';

export class TrackOutsideClicks extends Component<
  {
    onOutsideClick: () => void;
    removeOnOutsideClick?: boolean;
  } & PropsWithChildren
> {
  ref = createRef<HTMLDivElement>();

  constructor(props) {
    super(props);

    this.handleOutsideClick = this.handleOutsideClick.bind(this);
    document.addEventListener('click', this.handleOutsideClick);
  }

  componentWillUnmount() {
    document.removeEventListener('click', this.handleOutsideClick);
  }

  handleOutsideClick(event: MouseEvent) {
    if (!(event.target instanceof Node)) {
      return;
    }

    if (this.ref.current && !this.ref.current.contains(event.target)) {
      this.props.onOutsideClick();
      if (this.props.removeOnOutsideClick) {
        document.removeEventListener('click', this.handleOutsideClick);
      }
    }
  }

  render() {
    return <div ref={this.ref}>{this.props.children}</div>;
  }
}
