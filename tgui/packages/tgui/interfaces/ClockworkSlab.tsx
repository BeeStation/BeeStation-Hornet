import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  cogs: number;
  vitality: number;
  power: number;
  scriptures: ScriptureData[];
};

type ScriptureData = {
  name: string;
  desc: string;
  tip: string;
  type: string;
  cost: number;
  cog_cost: number;
  purchased: BooleanLike;
};

const tabs = ['Servitude', 'Preservation', 'Structures'] as const;

export const convertPower = (power_in) => {
  const units = ['W', 'kJ', 'MJ', 'GJ'];
  let power = 0;
  let value = power_in;
  while (value >= 1000 && power < units.length) {
    power++;
    value /= 1000;
  }
  return Math.round((value + Number.EPSILON) * 100) / 100 + units[power];
};

export function ClockworkSlab(props) {
  const [selectedTab, setSelectedTab] = useState('Servitude');

  return (
    <Window theme="clockwork" width={860} height={700}>
      <Window.Content>
        <ClockworkButtonSelection
          setSelectedTab={setSelectedTab}
          height="20%"
        />

        <Stack height="89%">
          <Stack.Item width="50%">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Stack.Item>

          <Stack.Item width="50%">
            <Stack vertical height="100%">
              <Stack.Item height="25%">
                <ClockworkOverview />
              </Stack.Item>
              <Stack.Item height="75%">
                <ClockworkHelp />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function ClockworkButtonSelection(props) {
  const { setSelectedTab } = props;

  return (
    <Section
      title={
        <Box inline color="good">
          <Icon name="cog" rotation={0} spin />
          {' Clockwork Slab '}
          <Icon name="cog" rotation={35} spin />
        </Box>
      }
    >
      <Stack>
        {tabs.map((tab) => (
          <Stack.Item key={tab} grow>
            <Button fluid onClick={() => setSelectedTab(tab)}>
              {tab}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function ClockworkSpellList(props) {
  const { act, data } = useBackend<Data>();
  const { cogs } = data;

  const { selectedTab } = props;

  const scriptures = filter(
    data.scriptures || [],
    (scripture) => scripture.type === selectedTab,
  );

  return (
    <Section title={selectedTab} fill scrollable>
      <Stack vertical fill>
        {scriptures.map((scripture, index) => (
          <Stack.Item key={scripture.name}>
            <Stack vertical>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow bold color="good" fontSize="16px">
                    {scripture.name}
                  </Stack.Item>

                  <Stack.Item>
                    <Button
                      disabled={
                        !scripture.purchased && cogs < scripture.cog_cost
                      }
                      onClick={() =>
                        act('invoke', {
                          scriptureName: scripture.name,
                        })
                      }
                    >
                      {scripture.purchased
                        ? `Invoke ${convertPower(scripture.cost)}`
                        : `${scripture.cog_cost} Cogs`}
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      disabled={!scripture.purchased}
                      onClick={() =>
                        act('quickbind', {
                          scriptureName: scripture.name,
                        })
                      }
                    >
                      Quickbind
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item>
                <Box italic p={1}>
                  {scripture.desc}
                </Box>
              </Stack.Item>

              {index !== scriptures.length - 1 ? <Divider /> : null}
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function ClockworkOverview(props) {
  const { data } = useBackend<Data>();
  const { power, cogs, vitality } = data;

  return (
    <Section
      title={
        <Box color="good" bold fontSize="16px">
          Celestial Gateway Report
        </Box>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <ClockworkOverviewStat
            title="Cogs"
            amount={cogs}
            maxAmount={cogs + 50 / cogs}
            iconName="cog"
          />
        </Stack.Item>
        <Stack.Item>
          <ClockworkOverviewStat
            title="Power"
            amount={power}
            maxAmount={power + 500000 / power}
            iconName="battery-half"
            overrideText={convertPower(power)}
          />
        </Stack.Item>
        <Stack.Item>
          <ClockworkOverviewStat
            title="Vitality"
            amount={vitality}
            maxAmount={vitality + 50 / vitality}
            iconName="tint"
            unit="u"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function ClockworkOverviewStat(props) {
  const {
    title,
    iconName,
    amount,
    maxAmount,
    unit = '',
    overrideText = '',
  } = props;

  return (
    <Stack height="22px" fontSize="16px">
      <Stack.Item width="20%">
        <Icon name={iconName} />
      </Stack.Item>
      <Stack.Item width="20%">{title}</Stack.Item>
      <Stack.Item width="60%">
        <ProgressBar
          value={amount}
          minValue={0}
          maxValue={maxAmount}
          ranges={{
            good: [maxAmount / 2, Infinity],
            average: [maxAmount / 4, maxAmount / 2],
            bad: [-Infinity, maxAmount / 4],
          }}
        >
          {overrideText || `${amount} ${unit}`}
        </ProgressBar>
      </Stack.Item>
    </Stack>
  );
}

function ClockworkHelp(props) {
  return (
    <Section title="Servants of the Cog vol.1" fill scrollable>
      <Stack vertical fill>
        <Stack.Item>
          <Collapsible title="Where To Start" open>
            <Section>
              After a long and destructive war, Rat&#39;Var has been imprisoned
              inside a dimension of suffering.
              <br />
              You are a group of his last remaining, most loyal servants.
              <br />
              You are very weak and have little power, with most of your
              scriptures unable to function.
              <br />
              <b>
                Use the&nbsp;
                <Box inline color="#BD78C4">
                  Ratvarian Observation Consoles&nbsp;
                </Box>
                to warp to the station!
              </b>
              <br />
              <b>
                Install&nbsp;
                <Box inline color="#DFC69C">
                  Integration Cogs&nbsp;
                </Box>
                to unlock more scriptures and siphon power!
              </b>
              <br />
              <b>
                Unlock&nbsp;
                <Box inline color="#D8D98D">
                  Kindle&nbsp;
                </Box>
                ,&nbsp;
                <Box inline color="#F19096">
                  Hateful Manacles&nbsp;
                </Box>
                and summon a&nbsp;
                <Box inline color="#9EA7E5">
                  Sigil of Submission&nbsp;
                </Box>
                to convert any non-believers!
              </b>
              <br />
            </Section>
          </Collapsible>
        </Stack.Item>
        <Stack.Item>
          <Collapsible title="Unlocking Scriptures">
            <Section>
              Most scriptures require <b>cogs</b> to unlock.
              <br />
              Invoke&nbsp;
              <Box inline bold color="#DFC69C">
                Integration Cog&nbsp;
              </Box>
              to summon an Integration Cog, which can be placed into any&nbsp;
              <b>APC&nbsp;</b>
              on the station.
              <br />
              Slice open the&nbsp;
              <b>APC&nbsp;</b>
              with the&nbsp;
              <b>Integration Cog&nbsp;</b>
              , then insert it in to begin siphoning power.
              <br />
            </Section>
          </Collapsible>
        </Stack.Item>
        <Stack.Item>
          <Collapsible title="Conversion">
            <Section>
              Invoke&nbsp;
              <Box inline bold color="#D8D98D">
                Kindle&nbsp;
              </Box>
              (After you unlock it), to&nbsp;
              <b>stun&nbsp;</b>
              and&nbsp;
              <b>mute&nbsp;</b>
              any target long enough for you to restrain
              <br />
              Using&nbsp;
              <Box inline bold>
                zipties&nbsp;
              </Box>
              obtained from the station, or by invoking&nbsp;
              <Box inline bold color="#F19096">
                Hateful Manacles&nbsp;
              </Box>
              , you can restrain targets to keep them from escaping the light.
              <br />
              Invoke&nbsp;
              <Box inline bold color="#D5B8DC">
                Abscond&nbsp;
              </Box>
              to warp back to Reebe, where the being you are dragging will be
              pulled with you.
              <br />
              From there, summon a&nbsp;
              <Box inline bold color="#9EA7E5">
                Sigil of Submission&nbsp;
              </Box>
              and hold them over it for 8 seconds. <br />
              You cannot enlighten those who have&nbsp;
              <b>mindshields.</b>
              <br />
              Make sure to take their&nbsp;
              <b>headset&nbsp;</b>
              so they don&#39;t spread misinformation!
              <br />
            </Section>
          </Collapsible>
        </Stack.Item>
        <Stack.Item>
          <Collapsible title="Defending Reebe">
            <Section>
              <b>
                You have a wide range of structures and powers that will be
                vital in defending the Celestial Gateway.
              </b>
              <br />
              <Box inline bold color="#B5FD9D">
                Replicant Fabricator:&nbsp;
              </Box>
              A powerful tool that can rapidly construct Brass structures, or
              convert most materials to Brass.
              <br />
              <Box inline bold color="#DED09F">
                Cogscarab:&nbsp;
              </Box>
              A small drone possessed by the spirits of the fallen soldiers
              which will protect Reebe while you go out and spread the truth!
              <br />
              <Box inline bold color="#FF9D9D">
                Clockwork Marauder:&nbsp;
              </Box>
              A powerful shell that can deflect ranged attacks and delivers a
              strong blow in close quarter combat.
              <br />
              <br />
            </Section>
          </Collapsible>
        </Stack.Item>
        <Stack.Item>
          <Collapsible title="Celestial Gateway">
            <Section>
              To summon Rat&#39;Var the&nbsp;
              <Box inline bold color="#E9E094">
                Celestial Gateway&nbsp;
              </Box>
              must be opened.
              <br />
              This can be done by having enough servants invoke&nbsp;
              <Box inline bold color="#B5FD9D">
                Celestial Gateway&nbsp;
              </Box>
              <br />
              After you enlighten enough of the crew, the&nbsp;
              <Box inline bold color="#E9E094">
                Celestial Gateway&nbsp;
              </Box>
              will be forced open.
              <br />
              <b>
                Make sure you are prepared for when the Gateway opens, since the
                entire crew will swarm to destroy it!
              </b>
              <br />
            </Section>
          </Collapsible>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
