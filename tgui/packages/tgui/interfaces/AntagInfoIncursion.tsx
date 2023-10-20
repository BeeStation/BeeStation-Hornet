import { useBackend } from '../backend';
import { Box, BlockQuote, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { AntagInfoHeader } from './common/AntagInfoHeader';

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

type Info = {
  members: string[];
  code: string;
  failsafe_code: string;
  has_uplink: BooleanLike;
  uplink_unlock_info: string;
  objectives: Objective[];
  antag_name: string;
};

const UplinkSubsection = (_props, context) => {
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

const MembersSubsection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { members } = data;
  return (
    <Section title="Members">
      <Stack vertical>
        {members.map((member) => (
          <Stack.Item key={member}>{member}</Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const BasicLoreSubsection = (_props, _context) => {
  return (
    <Section>
      <BlockQuote>
        You have joined a team of Syndicate agents with shared goals and must infiltrate the ranks of the station!
        <br />
        You&apos;ve been implanted with an internal syndicate radio implant for communication with your team. This headset can
        only be heard by you directly and if those pigs at Nanotrasen try to steal it they will violently explode!
        <br />
        Talk over the{' '}
        <Box inline textColor="red">
          Syndicate radio channel
        </Box>{' '}
        with{' '}
        <Box inline textColor="red">
          :t
        </Box>{' '}
        /{' '}
        <Box inline textColor="red">
          .t
        </Box>
      </BlockQuote>
    </Section>
  );
};

const InfoSection = (_props, _context) => {
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <MembersSubsection />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <BasicLoreSubsection />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <UplinkSubsection />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoIncursion = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives, antag_name } = data;
  return (
    <Window width={620} height={620} theme="syndicate">
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={antag_name || 'Syndicate Incursion Member'} asset="traitor.png" />
          </Stack.Item>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
