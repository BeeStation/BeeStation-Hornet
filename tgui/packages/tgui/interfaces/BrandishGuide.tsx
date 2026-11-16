import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type BrandishGuideData = {
  controls: { name: string; keys: string[] }[];
};

export const BrandishGuide = () => {
  const { act, data } = useBackend<BrandishGuideData>();

  return (
    <Window width={500} height={570} title="Brandish perspective">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow overflow="auto">
            <Section title="Face forward">
              Your character always faces the top of the screen. Turning rotates
              your view in 90-degree steps, with the camera looking two tiles
              ahead.
              <Box mt={1}>
                Your view is square: its width and height use the smaller of
                your requested view dimensions.
              </Box>
              <Box mt={1}>
                Default-direction station traits are for normal view and cannot
                be combined with Brandish.
              </Box>
            </Section>
            <Section title="Your movement keys">
              <LabeledList>
                {data.controls.map(({ name, keys }) => (
                  <LabeledList.Item key={name} label={name}>
                    {keys.filter((key) => key !== 'Unbound').join(' / ') ||
                      'Unbound'}
                  </LabeledList.Item>
                ))}
              </LabeledList>
              <Box mt={1} color="label">
                Backward movement takes twice as long as forward movement.
                Strafing takes four thirds as long (75% of forward speed).
              </Box>
            </Section>
            <Section title="Seats, spinning and settings">
              While seated, your view follows the chair. Turn keys do not turn
              your character separately. Using *spin on foot rotates your view
              with your character.
              <Box mt={1}>
                Change these keys in Game Preferences &gt; Keybindings &gt;
                Brandish movement keys. Sharing keys with ordinary bindings is
                allowed; Brandish controls take priority while this perspective
                is active, including in classic input mode.
              </Box>
              <Box mt={1}>
                Open this guide again from OOC &gt; Brandish Perspective Guide.
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button fluid textAlign="center" onClick={() => act('close')}>
              Got it
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
