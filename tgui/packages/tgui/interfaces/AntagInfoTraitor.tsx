import { useBackend } from '../backend';
import { BlockQuote, Section, Stack } from '../components';
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
  color: 'lightblue',
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
  intro: string;
  code: string;
  failsafe_code: string;
  has_uplink: BooleanLike;
  uplink_unlock_info: string;
  objectives: Objective[];
};

const ObjectivePrintout = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
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

const UplinkSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { has_uplink, uplink_unlock_info, code, failsafe_code } = data;
  return (
    <Section title="Uplink" mb={!has_uplink && -1}>
      <Stack fill>
        <Stack.Item bold>
          {code && <span style={goalstyle}>Code: {code}</span>}
          <br />
          {failsafe_code && <span style={badstyle}>Failsafe: {failsafe_code}</span>}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item mt="1%">
          <BlockQuote>{uplink_unlock_info}</BlockQuote>
        </Stack.Item>
      </Stack>
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
            You have not been supplied with codewords. You will have to use alternative methods to find potential allies.
            Proceed with caution, however, as everyone is a potential foe.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Your employer provided you with the following codewords to identify fellow agents. Use the codewords during
                regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.
                <span style={badstyle}>&ensp;You have memorized the codewords, allowing you to recognise them when heard.</span>
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

export const AntagInfoTraitor = (_props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Window width={620} height={580} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item>
            <UplinkSection />
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
