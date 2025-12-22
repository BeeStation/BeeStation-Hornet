import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

export const OrbitalHeightControl = (props) => {
  const { data } = useBackend();

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Section title="Orbital Height Control System">
          <p>System Status: Nominal</p>
          <p>This console is ready for future implementation.</p>
        </Section>
      </Window.Content>
    </Window>
  );
};
