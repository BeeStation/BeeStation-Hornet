import { detectOverflow, Modifier, Placement } from '@popperjs/core';
import {
  PropsWithChildren,
  ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { createPortal } from 'react-dom';
import { usePopper } from 'react-popper';

const MAX_SIZE_MODIFIER: Modifier<'maxSize', Record<string, unknown>> = {
  name: 'maxSize',
  enabled: true,
  phase: 'main',
  requiresIfExists: ['offset'],
  fn({ state }) {
    const overflow = detectOverflow(state, { padding: 8 });
    const { height } = state.rects.popper;
    const basePlacement = state.placement.split('-')[0];
    const heightProp = basePlacement === 'top' ? 'top' : 'bottom';

    state.modifiersData.maxSize = {
      height: height - overflow[heightProp],
    };
  },
};

const APPLY_MAX_SIZE_MODIFIER: Modifier<
  'applyMaxSize',
  Record<string, unknown>
> = {
  name: 'applyMaxSize',
  enabled: true,
  phase: 'beforeWrite',
  requires: ['maxSize'],
  fn({ state }) {
    const { height } = state.modifiersData.maxSize;
    state.styles.popper.maxHeight = `${height}px`;
  },
};

const POPPER_MODIFIERS = [MAX_SIZE_MODIFIER, APPLY_MAX_SIZE_MODIFIER];

type RequiredProps = {
  /** The content to display in the popper */
  content: ReactNode;
  /** Whether the popper is open */
  isOpen: boolean;
};

type OptionalProps = Partial<{
  /** Called when the user clicks outside the popper */
  onClickOutside: () => void;
  /** Where to place the popper relative to the reference element */
  placement: Placement;
}>;

type Props = RequiredProps & OptionalProps;

/**
 * ## Popper
 *  Popper lets you position elements so that they don't go out of the bounds of the window.
 * @url https://popper.js.org/react-popper/ for more information.
 */
export function Popper(props: PropsWithChildren<Props>) {
  const { children, content, isOpen, onClickOutside, placement } = props;

  const [referenceElement, setReferenceElement] =
    useState<HTMLDivElement | null>(null);
  const [popperElement, setPopperElement] = useState<HTMLDivElement | null>(
    null,
  );

  // One would imagine we could just use useref here, but it's against react-popper documentation and causes a positioning bug
  // We still need them to call focus and clickoutside events :(
  const popperRef = useRef<HTMLDivElement | null>(null);
  const parentRef = useRef<HTMLDivElement | null>(null);

  const { styles, attributes } = usePopper(referenceElement, popperElement, {
    placement,
    modifiers: POPPER_MODIFIERS,
  });

  /** Close the popper when the user clicks outside */
  function handleClickOutside(event: MouseEvent) {
    if (
      !popperRef.current?.contains(event.target as Node) &&
      !parentRef.current?.contains(event.target as Node)
    ) {
      onClickOutside?.();
    }
  }

  useEffect(() => {
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    } else {
      document.removeEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  return (
    <>
      <div
        ref={(node) => {
          setReferenceElement(node);
          parentRef.current = node;
        }}
      >
        {children}
      </div>
      {isOpen &&
        createPortal(
          <div
            ref={(node) => {
              setPopperElement(node);
              popperRef.current = node;
            }}
            style={{
              ...styles.popper,
              zIndex: 5,
              overflowY: 'auto',
            }}
            {...attributes.popper}
          >
            {content}
          </div>,
          document.body,
        )}
    </>
  );
}
