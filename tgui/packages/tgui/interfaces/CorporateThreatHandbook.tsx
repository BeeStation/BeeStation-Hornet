import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

type Data = {
  handbook_title: string;
  handbook_author: string;
};

export const CorporateThreatHandbook = (props) => {
  const { data } = useBackend<Data>();
  const { handbook_title, handbook_author } = data;

  return (
    <Window width={500} height={600} title={handbook_title}>
      <Window.Content scrollable>
        <Section title="Introduction">
          This handbook has been prepared by the Nanotrasen Security Division to
          brief all crew members on potential threats they may encounter during
          their shift.
        </Section>
        <Section title="Author">{handbook_author}</Section>
        <Section title="Contents">
          {/* Boilerplate - Content sections will be added here */}
          <p>Content coming soon...</p>
        </Section>
      </Window.Content>
    </Window>
  );
};
