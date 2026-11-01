import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Section } from 'tgui-core/components';

import { Window } from '../../layouts';
import { CdrContent, CdrData } from './CdrContent';
import { CdrHelpMenu } from './CdrHelpMenu';

export const AtmosCdr = (props) => {
  const { act, data } = useBackend<CdrData>();
  const [helpMenuOpen, setHelpMenuOpen] = useState(false);
  return (
    <Window height={600} width={475}>
      <Window.Content scrollable>
        <Section
        title="CDR Monitoring & Control Panel"
        fitted
        buttons={
          <Button
            icon="question"
            selected={helpMenuOpen}
            onClick={() => setHelpMenuOpen(!helpMenuOpen)} />} />
        {helpMenuOpen ? <CdrHelpMenu /> : <CdrContent {...data} />}
      </Window.Content>
    </Window>
  );
};
