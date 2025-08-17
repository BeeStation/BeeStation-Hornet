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

const IntroSection = (_props) => {
  const { data } = useBackend<Info>();
  const { mothership } = data;
  return (
    <Stack>
      <Stack.Item>
        <Box
          inline
          as="img"
          src={resolveAsset('ayylmao.png')}
          width="64px"
          style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated' }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ position: 'relative', top: '25%', left: '-2%' }}>
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

const BasicLoreSection = (_props) => {
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
        As an abductor, you have a telepathic link with all other abductors, and have no method of verbal communication.
      </BlockQuote>
    </Section>
  );
};

const WikiSection = (_props) => {
  return (
    <Section>
      <BlockQuote>
        <Box italic bold textColor="purple">
          But what do I do next?
        </Box>
        First things first. You may always use the{' '}
        <Box inline bold textColor="red">
          navigate
        </Box>{' '}
        button to the left of your combat mode button for assistance.
        <br />- You will probably have woken up in your resting contraption.{' '}
        <Box inline textColor="pink">
          Examine the doors.
        </Box>
        <br />- It will be labelled with either Alpha △, Beta ▼, Gamma ▲, or Delta ▽. This is your{' '}
        <Box inline bold textColor="blue">
          team.
        </Box>
        <br />- Now find the door in your quarters labelled with ⊝. This is the path to the ready-room.
        <br />- Head in there, open one of the lockers, and equip yourself. Your scientist buddy will wait for you in the
        control center.
        <br />- <b>Make sure both your vest and the scientist&apos;s science tool are linked to the console of your team.</b>
        <br />-{' '}
        <Box inline textColor="pink">
          Examine
        </Box>{' '}
        them to ensure they are. Examining anything in your ship will likely yield important information.
        <br />- The ship is organised as follows:{' '}
        <Box inline textColor="pink">
          The top section houses quarters and the readyrooms.
        </Box>
        <br />-{' '}
        <Box inline textColor="purple">
          The bottom section houses maintenance areas.
        </Box>{' '}
        <br />-{' '}
        <Box inline bold>
          Your workplace is on either to the left or right of the control center.
        </Box>{' '}
        <br />- The scientist controls teleportation from the control room, you yourself as well as subjects are brought in via
        the teleportation rooms, operated on in the surgery rooms, and returned via the experimentation rooms.
        <br />- That&apos;s mostly it! For more detail, ask the mentors or consult the wiki!
      </BlockQuote>
    </Section>
  );
};

const EquipmentSection = (_props) => {
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
                style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated' }}
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
                style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated' }}
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
              style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated' }}
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

export const AntagInfoAbductorAgent = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={620} height={950} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item>
            <BasicLoreSection />
            <WikiSection />
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
