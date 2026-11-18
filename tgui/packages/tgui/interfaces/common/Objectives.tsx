import type { ReactNode } from 'react';
import { Box, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { sanitizeText } from '../../sanitize';

export type Objective = {
  // The title of the objective, not actually displayed so optional
  name?: string;
  // What "number" objective this is, IE, its index in the list of objectives
  count: number;
  // The text explaining what this objective requires
  explanation: string;
  // Whether or not this objective is completed
  complete?: BooleanLike;
  // Whether the objective is optional or not
  optional?: BooleanLike;
};

type ObjectivePrintoutProps = {
  // For passing onto the Stack component
  fill?: boolean;
  // Allows additional components to follow the printout in the same stack
  objectiveFollowup?: ReactNode;
  // The prefix to use for each objective, defaults to "#" (#1, #2)
  objectivePrefix?: string;
  // The font size to use for each objective
  objectiveTextSize?: string;
  // The objectives to print out
  objectives: Objective[];
  // The title to use for the printout, defaults to "Your current objectives"
  titleMessage?: string;
};

export const ObjectivePrintout = (props: ObjectivePrintoutProps) => {
  const {
    fill,
    objectiveFollowup,
    objectivePrefix,
    objectiveTextSize,
    objectives = [],
    titleMessage,
  } = props;

  return (
    <Stack fill={fill} vertical>
      <Stack.Item bold>{titleMessage || `Your current objectives`}:</Stack.Item>
      <Stack.Item>
        {(objectives.length === 0 && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item fontSize={objectiveTextSize} key={objective.count}>
              {objectivePrefix || '#'}
              {objective.count}:{' '}
              {!!objective.optional && (
                <Box inline textColor="green">
                  Optional:{' '}
                </Box>
              )}
              <span
                // eslint-disable-next-line react/no-danger
                dangerouslySetInnerHTML={{
                  __html: sanitizeText(objective.explanation, false),
                }}
              />
            </Stack.Item>
          ))}
      </Stack.Item>
      {!!objectiveFollowup && <Stack.Item>{objectiveFollowup}</Stack.Item>}
    </Stack>
  );
};

type ObjectivesSectionProps = {
  objectives: Objective[];
};

export const ObjectivesSection = (props: ObjectivesSectionProps) => {
  const { objectives } = props;
  return (
    <Section fill title="Objectives" scrollable>
      <ObjectivePrintout objectives={objectives} />
    </Section>
  );
};
