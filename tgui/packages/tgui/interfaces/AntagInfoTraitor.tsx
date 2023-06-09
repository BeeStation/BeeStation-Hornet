import { useBackend } from '../backend';
import { Box, BlockQuote, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

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
  optional: BooleanLike;
};

type Info = {
  antag_name: string;
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  code: string;
  failsafe_code: string;
  has_uplink: BooleanLike;
  uplink_unlock_info: string;
  objectives: Objective[];
};

const IntroSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { antag_name } = data;
  return (
    <Stack>
      <Stack.Item>
        <Box
          inline
          as="img"
          src={resolveAsset('traitor.png')}
          width="64px"
          style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ 'position': 'relative', 'top': '25%', 'left': '25%' }}>
          You are the{' '}
          <Box inline textColor="bad">
            {antag_name || 'Traitor'}
          </Box>
          !
        </h1>
      </Stack.Item>
    </Stack>
  );
};

const ObjectivesSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Section fill title="Objectives" scrollable>
      <Stack vertical>
        <Stack.Item bold>Your current objectives:</Stack.Item>
        <Stack.Item>
          {(!objectives && 'None!') ||
            objectives.map((objective) => (
              <Stack.Item key={objective.count}>
                #{objective.count}:{' '}
                {!!objective.optional && (
                  <Box inline textColor="green">
                    Optional:
                  </Box>
                )}{' '}
                {objective.explanation}{' '}
              </Stack.Item>
            ))}
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
      <Stack vertical>
        <Stack.Item>
          <BlockQuote>
            Keep this uplink safe, and don&apos;t feel like you need to buy everything immediately — you can save your
            telecrystals to use whenever you&apos;re in a tough situation and need help.
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack fill>
            <Stack.Item bold>{code && <span style={goalstyle}>Code: {code}</span>}</Stack.Item>
            <Stack.Divider />
            {failsafe_code && (
              <>
                <Stack.Item bold>{code && <span style={goalstyle}>Code: {code}</span>}</Stack.Item>
                <Stack.Divider />
              </>
            )}
            <Stack.Item>
              <BlockQuote>{uplink_unlock_info}</BlockQuote>
            </Stack.Item>
          </Stack>
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

export const AntagInfoTraitor = (_props, _context) => {
  return (
    <Window width={620} height={620} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection />
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
