import { useBackend } from '../backend';
import { Box, BlockQuote, Section, Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { resolveAsset } from '../assets';

type Info = {
  members: string[];
  mothership: string;
  objectives: Objective[];
};

const IntroSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { mothership } = data;
  return (
    <Stack>
      <Stack.Item>
        <Box
          inline
          as="img"
          src={resolveAsset('ayylmao.png')}
          width="64px"
          style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ 'position': 'relative', 'top': '25%', 'left': '-2%' }}>
          You are the{' '}
          <Box inline textColor="purple">
            Abductor
          </Box>{' '}
          <Box inline textColor="red">
            Agent
          </Box>{' '}
          of{' '}
          <Box inline textColor="purple">
            {mothership}
          </Box>
          !
        </h1>
      </Stack.Item>
    </Stack>
  );
};

const BasicLoreSection = (_props, _context) => {
  return (
    <Section>
      <BlockQuote>
        You are the{' '}
        <Box inline textColor="red">
          agent
        </Box>{' '}
        of this abductor team!
        <br />
        You&apos;re the <b>brawn</b> of the abductors, it is your job to work with your{' '}
        <Box inline textColor="blue">
          scientist
        </Box>{' '}
        to capture test subjects and bring them back to your ship!
        <br />
        As an abductor, you have a telepathic link with your partner, and have no method of verbal communication.
      </BlockQuote>
    </Section>
  );
};

const EquipmentSection = (_props, _context) => {
  return (
    <Section title="Equipment">
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box
                inline
                as="img"
                src={resolveAsset('abaton.png')}
                width="32px"
                style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
              />
              Your{' '}
              <Box inline textColor="purple">
                advanced baton
              </Box>{' '}
              is a multi-purpose baton that does just about everything you need to subdue someone. It has four modes:
              <br />
              <Box inline textColor="yellow">
                Stun
              </Box>
              : Stuns whoever you hit it with.
              <br />
              <Box inline textColor="blue">
                Sleep
              </Box>
              : Knocks someone out, as long as they&apos;re stunned. Only one person can be asleep at a time, however!
              <br />
              <Box inline textColor="red">
                Cuff
              </Box>
              : Cuffs someone with hard-light energy cuffs.
              <br />
              <Box inline textColor="purple">
                Probe
              </Box>
              : Probes whether an organism is suitable for experimentation or not.
              <br />
              People wearing{' '}
              <Box inline textColor="label">
                tinfoil hats
              </Box>{' '}
              are immune to the baton&apos;s effects, however.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Box
                inline
                as="img"
                src={resolveAsset('atool.png')}
                width="32px"
                style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
              />
              You have{' '}
              <Box inline textColor="purple">
                alien tools
              </Box>{' '}
              , which are capable of working extremely fast, faster than any tool available to lesser lifeforms.
              <br />
              You can use these to{' '}
              <Box inline textColor="yellow">
                hack machinery
              </Box>{' '}
              or{' '}
              <Box inline textColor="orange">
                weld doors shut
              </Box>
              , for example.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack.Item>
            <Box
              inline
              as="img"
              src={resolveAsset('apistol.png')}
              width="32px"
              style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
            />
            Your{' '}
            <Box inline textColor="purple">
              alien pistol
            </Box>{' '}
            is an effective self-defense weapon, with three different fire modes:
            <br />
            <Box inline textColor="green">
              Declone
            </Box>
            : Deals 20 cellular damage to whatever it hits.
            <br />
            <Box inline textColor="blue">
              Ion
            </Box>
            : EMPs whatever it hits.
            <br />
            <Box inline textColor="teal">
              Freeze
            </Box>
            : Lowers the temperature of whatever it hits.
          </Stack.Item>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoAbductorAgent = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Window width={620} height={650} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item>
            <BasicLoreSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
          <Stack.Item>
            <EquipmentSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
