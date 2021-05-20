import { useBackend } from '../backend';
import { Box, Button, Table, Section, NoticeBox } from '../components';
import { toTitleCase } from 'common/string';
import { Window } from '../layouts';

export const EightBallVote = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    shaking,
  } = data;
  return (
    <Window
      width={400}
      height={600}>
      <Window.Content scrollable>
        {!shaking && (
          <NoticeBox>
            No question is currently being asked.
          </NoticeBox>
        ) || (
          <EightBallVoteQuestion />
        )}
      </Window.Content>
    </Window>
  );
};

const EightBallVoteQuestion = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    question,
    answers = [],
  } = data;
  return (
    <Section>
      <Box
        bold
        textAlign="center"
        fontSize="16px"
        m={1}>
        &quot;{question}&quot;
      </Box>
      <Table>
        {answers.map(answer => (
          <Table.Row key={answer.answer}>
            <Button
              fluid
              bold
              content={toTitleCase(answer.answer)}
              selected={answer.selected}
              fontSize="16px"
              lineHeight="24px"
              textAlign="center"
              mb={1}
              onClick={() => act('vote', {
                answer: answer.answer,
              })} />
            <Box
              bold
              textAlign="center"
              fontSize="30px">
              {answer.amount}
            </Box>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
