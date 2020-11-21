import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const Vote = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    choices,
    voting,
    time_remaining,
  } = data;
  return (
    <Window
      title="Vote"
      width={400}
      height={500}>
      <Window.Content>
        <Section title="Start a vote">
          <Button
            onClick={() => act('restart')}>
            Begin a restart vote
          </Button>
          <Box fontSize={1.5}>
            {time_remaining} s
          </Box>
        </Section>
        <Section title="Choices">
          {choices?.map((choice, i) => (
            <Box key={i} mb={1}>
              <Button
                onClick={() => act('vote', {
                  index: i + 1,
                })}>
                {choice.name}
              </Button>
              {` Votes: ${choice.votes}`}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
