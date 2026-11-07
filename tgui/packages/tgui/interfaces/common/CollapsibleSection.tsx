import { useState } from 'react';
import { Button, Section } from 'tgui-core/components';

export function CollapsibleSection(props) {
  const {
    children,
    startOpen = true,
    sectionKey,
    color,
    buttons = [],
    forceOpen = false,
    showButton = !forceOpen,
    ...rest
  } = props;

  const [isOpen, setOpen] = useState(startOpen);

  return (
    <Section
      fitted={!forceOpen && !isOpen}
      buttons={
        showButton && (
          <>
            {buttons}
            {
              <Button
                fluid
                color={forceOpen || isOpen ? 'transparent' : color}
                icon={forceOpen || isOpen ? 'chevron-down' : 'chevron-left'}
                onClick={() => setOpen(!isOpen)}
              />
            }
          </>
        )
      }
      {...rest}
    >
      {forceOpen || isOpen ? children : null}
    </Section>
  );
}
