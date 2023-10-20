import { useBackend } from '../backend';
import { Box, Section, Button, Icon } from '../components';
import { Window } from '../layouts';

export const PictureSelectModal = (_, context) => {
  const { data, act } = useBackend(context);
  const { title, pictures = [], button_text } = data;
  return (
    <Window title={title} width={400} height={500}>
      <Window.Content scrollable>
        {pictures.map((picture) => (
          <Section
            title={
              <>
                <Icon name="camera" /> {picture.name}
              </>
            }
            key={picture.ref}
            buttons={<Button content={button_text} color="green" onClick={() => act('submit', { entry: picture.ref })} />}
            style={{ overflow: 'auto' }}>
            <Box mt={1} as="img" src={picture.path} style={{ float: 'left', margin: '0.5em', marginTop: '0' }} />
            <span style={{ display: 'inline-block' }}>{picture.desc}</span>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
