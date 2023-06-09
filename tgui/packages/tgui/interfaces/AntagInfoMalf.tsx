import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Button, Section, Stack, Tabs } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const allystyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Info = {
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  objectives: Objective[];
};

const ObjectivePrintout = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your prime objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              &#8805-{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

const ObjectivesSection = (_props, _context) => {
  return (
    <Section fill title="Objectives" scrollable>
      <ObjectivePrintout />
    </Section>
  );
};

const CodewordsSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Codewords" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            You have not been supplied the Syndicate codewords. You will have to use alternative methods to find potential
            allies. Proceed with caution, however, as everyone is a potential foe.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                New access to restricted channels has provided you with intercepted syndicate codewords. Syndicate agents will
                respond as if you&apos;re one of their own. Proceed with caution, however, as everyone is a potential foe.
                <span style={badstyle}>
                  &ensp;The speech recognition subsystem has been configured to flag these codewords.
                </span>
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider mr={1} />
            <Stack.Item grow basis={0}>
              <Stack vertical>
                <Stack.Item>Code Phrases:</Stack.Item>
                <Stack.Item bold textColor="blue">
                  {phrases}
                </Stack.Item>
                <Stack.Item>Code Responses:</Stack.Item>
                <Stack.Item bold textColor="red">
                  {responses}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoMalf = (_props, _context) => {
  return (
    <Window width={660} height={530} theme="hackerman">
      <Window.Content style={{ 'font-family': 'Consolas, monospace' }}>
        <Stack vertical fill>
          <Stack.Item grow>
            <ObjectivesSection />
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
