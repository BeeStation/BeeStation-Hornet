import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';

const teleportstyle = {
  color: 'yellow',
};

const robestyle = {
  color: 'lightblue',
};

const destructionstyle = {
  color: 'red',
};

const defensestyle = {
  color: 'orange',
};

const transportstyle = {
  color: 'yellow',
};

const summonstyle = {
  color: 'cyan',
};

const ritualstyle = {
  color: 'violet',
};

type Info = {
  objectives: Objective[];
};

const IntroSection = (_props, _context) => {
  return (
    <Stack>
      <Stack.Item>
        <Box
          inline
          as="img"
          src={resolveAsset('wizard.png')}
          width="64px"
          style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ 'position': 'relative', 'top': '25%', 'left': '25%' }}>
          You are the{' '}
          <Box inline textColor="bad">
            Wizard
          </Box>
          !
        </h1>
      </Stack.Item>
    </Stack>
  );
};

const SpellbookSection = (_props, _context) => {
  return (
    <Section fill title="Spellbook">
      <Stack vertical fill>
        <Stack.Item>
          You have a spellbook which is bound to you. You can use it to choose a magical arsenal.
          <br />
          <span style={destructionstyle}>The deadly page has the offensive spells, to destroy your enemies.</span>
          <br />
          <span style={defensestyle}>
            The defensive page has defensive spells, to keep yourself alive. Remember, you may be powerful, but you are still
            only human.
          </span>
          <br />
          <span style={transportstyle}>
            The transport page has mobility spells, very important aspect of staying alive and getting things done.
          </span>
          <br />
          <span style={summonstyle}>
            The summoning page has summoning and other helpful spells for not fighting alone. Careful, not every summon is on
            your side.
          </span>
          <br />
          <span style={ritualstyle}>
            The rituals page has powerful global effects, that will pit the station against itself. Do mind that these are
            either expensive, or just for panache.
          </span>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MiscGearSection = (_props, _context) => {
  return (
    <Section title="Misc Gear">
      <Stack>
        <Stack.Item>
          <span style={teleportstyle}>Teleport scroll:</span> 4 uses to teleport wherever you want. You will not be able to come
          back to the den, so be sure you have everything ready before departing.
          <br />
          <span style={robestyle}>Wizard robes:</span> Used to cast most spells. Your spellbook will let you know which spells
          cannot be cast without a garb.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoWizard = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Window width={620} height={620} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
          <Stack.Item>
            <SpellbookSection />
          </Stack.Item>
          <Stack.Item>
            <MiscGearSection />
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="20px">
              Remember: Do not forget to prepare your spells.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
