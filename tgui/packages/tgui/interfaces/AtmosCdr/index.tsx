import { useBackend } from 'tgui/backend';

import { Window } from '../../layouts';
import { CdrContent, CdrData } from './CdrContent';

export const AtmosCdr = (props) => {
  const { data } = useBackend<CdrData>();
  return (
    <Window width={550} height={420}>
      <Window.Content scrollable>
        <CdrContent {...data} />
      </Window.Content>
    </Window>
  );
};
