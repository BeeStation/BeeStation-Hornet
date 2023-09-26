import { BooleanLike } from 'common/react';
import { Box, Section, Stack } from '../../components';
import { sanitizeText } from '../../sanitize';

export type Objective = {
  count: number;
  name: string;
  explanation: string;
  optional: BooleanLike;
};

type Props = {
  objectives: Objective[];
};

export const ObjectivesSection = (props: Props, _context) => {
  const { objectives } = props;
  return (
    <Section fill title="Objectives" scrollable>
      <Stack vertical>
        <Stack.Item bold>Your current objectives:</Stack.Item>
        <Stack.Item>
          {(!objectives && 'None!') ||
            objectives.map((objective) => (
              <Stack.Item key={objective.count}>
                #{objective.count}:{' '}
                <span
                  // eslint-disable-next-line react/no-danger
                  dangerouslySetInnerHTML={{
                    __html: sanitizeText(objective.explanation),
                  }}
                />
              </Stack.Item>
            ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
