import { Newscaster } from '../interfaces/Newscaster';
import { Window } from '../layouts';

export const PhysicalNewscaster = () => {
  return (
    <Window width={920} height={710}>
      <Window.Content scrollable>
        <Newscaster />
      </Window.Content>
    </Window>
  );
};
