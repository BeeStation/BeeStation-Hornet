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
          <Box inline textColor="blue">
            Scientist
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
        <Box inline textColor="blue">
          scientist
        </Box>{' '}
        of this abductor team!
        <br />
        You&apos;re the <b>brains</b> of the abductors, it is your job to work with your{' '}
        <Box inline textColor="red">
          agent
        </Box>{' '}
        to capture test subjects and bring them back to your ship for experimentation!
        <br />
        As an abductor, you have a telepathic link with your partner, and have no method of verbal communication.
      </BlockQuote>
    </Section>
  );
};

const SurgerySubsection = (_props, _context) => {
  return (
    <Section name="Experimentation">
      Whenever you have successfully abducted a target to your mothership, you experiment on them with an{' '}
      <Box inline textColor="purple">
        experimental organ replacement
      </Box>{' '}
      surgery. This surgery does not require you to strip the target, and consists of the following steps:
      <br />
      <b>1.</b>: Targeting their chest, click on the subject with{' '}
      <Box inline textColor="blue">
        surgical drapes
      </Box>{' '}
      and select{' '}
      <Box inline textColor="purple">
        experimental organ manipulation
      </Box>
      .
      <br />
      <b>2.</b>: Make an incision in the subject using a{' '}
      <Box inline textColor="blue">
        scalpel
      </Box>
      .
      <br />
      <b>3.</b>: Clamp bleeders into the subject using a{' '}
      <Box inline textColor="blue">
        hemostat
      </Box>
      .
      <br />
      <b>4.</b>: Retract the subject&apos;s skin using{' '}
      <Box inline textColor="blue">
        retractors
      </Box>
      .
      <br />
      <b>5.</b>: Make another incision in the subject using a{' '}
      <Box inline textColor="blue">
        scalpel
      </Box>
      .
      <br />
      <b>6.</b>: Extract the subject&apos; organs using an{' '}
      <Box inline textColor="blue">
        empty hand
      </Box>
      .
      <br />
      <b>7.</b>: Insert an experimental{' '}
      <Box inline textColor="blue">
        alien organ
      </Box>{' '}
      into the subject.
      <br />
      <b>8.</b>: Move the target into the{' '}
      <Box inline textColor="purple">
        experimentation machine
      </Box>{' '}
      via drag-clicking, ensuring they are unbuckled from your operating table. Select either Probe, Analyze, or Dissect once
      they are in there.
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
                src={resolveAsset('scitool.png')}
                width="32px"
                style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
              />
              Your{' '}
              <Box inline textColor="purple">
                science tool
              </Box>{' '}
              is essential for abducting test subjects for experimentation! It has two modes:
              <br />
              <Box inline textColor="blue">
                Mark
              </Box>
              : Marks a subject, allowing them to be beamed up by your camera console. You can mark your agent instantly from
              any range (even from the cameras), however test subjects require you to beam down to them and mark them yourself!
              <br />
              <Box inline textColor="red">
                Scan
              </Box>
              : Scans someone, adding their appearance to the potential disguises for your agent. This works from the cameras.
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
                alien surgical tools
              </Box>{' '}
              , which are capable of working extremely fast, faster than any tool available to lesser lifeforms.
              <br />
              These are essential to performing experimental surgeries on abducted test subjects!
              <br />
              In addition, you are capable of doing other high-tech surgeries, such as{' '}
              <Box inline textColor="purple">
                brainwashing
              </Box>{' '}
              or{' '}
              <Box inline textColor="green">
                max-tier wound tending
              </Box>
              .
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <SurgerySubsection />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoAbductorScientist = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Window width={620} height={620} theme="abductor">
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
