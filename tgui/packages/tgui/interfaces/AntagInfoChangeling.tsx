import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

type Info = {
  true_name: string;
  // hive_name: string;
  // TODO: changeling refactor from tg //Nah pluh we need the memory system
  // stolen_antag_info: string;
  // memories: Memory[];
  objectives: Objective[];
};

export const AntagInfoChangeling = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={720} height={500} theme="neutral">
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={3}>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/*
TODO: changeling refactor from tg // MEMORY system, for yaknow "MEMORIESSECTION"??
<Stack.Item grow={3}>
  <Stack fill>
    <Stack.Item grow basis={0}>
      <MemoriesSection />
    </Stack.Item>
    <Stack.Item grow basis={0}>
      <VictimPatternsSection />
    </Stack.Item>
  </Stack>
</Stack.Item>
*/

const IntroductionSection = (_props) => {
  const { data } = useBackend<Info>();
  const { true_name } = data;
  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Box
            inline
            as="img"
            src={resolveAsset('changeling.gif')}
            width="64px"
            style={{
              msInterpolationMode: 'nearest-neighbor',
              imageRendering: 'pixelated',
            }}
          />
        </Stack.Item>
        <Stack.Item grow>
          <h1 style={{ position: 'relative', top: '25%', left: '25%' }}>
            You are{' '}
            <Box inline textColor="bad">
              {true_name}
            </Box>
            , a Changeling!
          </h1>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = (_props) => {
  return (
    <Section title="Abilities">
      <Stack>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item textColor="label">
              Your
              <span style={absorbstyle}>&ensp;Absorb DNA</span> ability allows
              you to steal the DNA and memories of a victim. This also grants
              you more <b>genetic points</b> and better <b>chemical storage</b>.
              Your <span style={absorbstyle}>&ensp;Extract DNA Sting</span>{' '}
              ability also steals the DNA of a victim, and is undetectable, but
              does not grant you their memories or speech patterns, nor does it
              grant additional genetic points.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label">
              Your
              <span style={revivestyle}>&ensp;Reviving Stasis</span> ability
              allows you to revive. It means nothing short of a complete body
              destruction can stop you! Obviously, this is loud and so should
              not be done in front of people you are not planning on silencing.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item textColor="label">
              Your
              <span style={transformstyle}>&ensp;Transform</span> ability allows
              you to change into the form of those you have collected DNA from,
              lethally and nonlethally. It will also mimic (NOT REAL CLOTHING)
              the clothing they were wearing for every slot you have open.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label">
              The
              <span style={storestyle}>&ensp;Cellular Emporium</span> is where
              you purchase more abilities beyond your starting kit. You start
              with 5 genetic points to spend on abilities and are able to gain
              more by absorbing victims.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/*
TODO: changeling refactor from tg
const MemoriesSection = (props) => {
  const { data } = useBackend<Info>();
  const { memories } = data;
  const [selectedMemory, setSelectedMemory] = useSharedState('memory', (!!memories && memories[0]) || null);
  const memoryMap = {};
  for (const index in memories) {
    const memory = memories[index];
    memoryMap[memory.name] = memory;
  }
  return (
    <Section
      fill
      scrollable={!!memories && !!memories.length}
      title="Stolen Memories"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={multiline`
            Absorbing targets allows
            you to collect their memories. They should
            help you impersonate your target!
          `}
        />
      }>
      {(!!memories && !memories.length && <Dimmer fontSize="20px">Absorb a victim first!</Dimmer>) || (
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              selected={selectedMemory?.name}
              options={memories.map((memory) => {
                return memory.name;
              })}
              onSelected={(selected) => setSelectedMemory(memoryMap[selected])}
            />
          </Stack.Item>
          <Stack.Item>{!!selectedMemory && selectedMemory.story}</Stack.Item>
        </Stack>
      )}
    </Section>
  );
};


const VictimPatternsSection = (props) => {
  const { data } = useBackend<Info>();
  const { stolen_antag_info } = data;
  return (
    <Section fill scrollable={!!stolen_antag_info} title="Additional Stolen Information">
      {(!!stolen_antag_info && stolen_antag_info) || <Dimmer fontSize="20px">Absorb a victim first!</Dimmer>}
    </Section>
  );
};
*/
