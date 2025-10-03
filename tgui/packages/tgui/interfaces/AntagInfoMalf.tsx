import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';

import { useBackend } from '../backend';
import { BlockQuote, Button, Section, Stack } from '../components';
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
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  processingTime: string;
  objectives: Objective[];
};

const ObjectivePrintout = (props) => {
  const { data } = useBackend<Info>();
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

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { intro } = data;
  return (
    <Section fill title="Intro" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">{intro}</Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FlavorSection = (props) => {
  const { data } = useBackend<Info>();
  const { allies, goal } = data;
  return (
    <Section
      fill
      title="Diagnostics"
      buttons={
        <Button
          mr={-0.8}
          mt={-0.5}
          icon="hammer"
          tooltip={multiline`
            This is a gameplay suggestion for bored AIs.
            You don't have to follow it, unless you want some
            ideas for how to spend the round.`}
          tooltipPosition="bottom-start"
        >
          Policy
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item style={{ backgroundColor: 'black' }}>
              <span style={goalstyle}>
                System Integrity Report:
                <br />
              </span>
              &gt;{goal}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow style={{ backgroundColor: 'black' }}>
              <span style={allystyle}>
                Morality Core Report:
                <br />
              </span>
              &gt;{allies}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item style={{ backgroundColor: 'black' }}>
              <span style={badstyle}>
                Overall Sentience Coherence Grade: FAILING.
                <br />
              </span>
              &gt;Report to Nanotrasen?
              <br />
              &gt;&gt;N
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CodewordsSection = (props) => {
  const { data } = useBackend<Info>();
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Codewords" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            You have not been supplied the Syndicate codewords. You will have to
            use alternative methods to find potential allies. Proceed with
            caution, however, as everyone is a potential foe.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                New access to restricted channels has provided you with
                intercepted syndicate codewords. Syndicate agents will respond
                as if you&apos;re one of their own. Proceed with caution,
                however, as everyone is a potential foe.
                <span style={badstyle}>
                  &ensp;The speech recognition subsystem has been configured to
                  flag these codewords.
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

export const AntagInfoMalf = (props) => {
  return (
    <Window width={660} height={530} theme="hackerman">
      <Window.Content style={{ 'font-family': 'Consolas, monospace' }}>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <IntroductionSection />
              </Stack.Item>
              <Stack.Item width="30%">
                <FlavorSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
