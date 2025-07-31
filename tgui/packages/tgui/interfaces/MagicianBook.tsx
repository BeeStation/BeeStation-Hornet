import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, Input, NoticeBox, ProgressBar, Section, Stack, Tabs, LabeledList } from '../components';
import { Window } from '../layouts';
import { ReactNode } from 'react';

import React, { useState } from 'react';

type MagicianBookData = {
  owner?: string;
  magicknowledge?: number;
  magician_level: string;
  magician_xp: number;
  magician_xp_to_next: number;
  magician_entry?: Array<{
    title: string;
    description: string;
    category: string;
    cost: number;
    ref: byondRef;
    times: number;
    cooldown: number;
    requires_magician_focus: BooleanLike;
    limit: number;
    is_spell?: boolean;
  }>;
};

type byondRef = string;

type SpellEntry = {
  // Name of the spell
  name: string;
  // Description of what the spell does
  desc: string;
  // Byond REF of the spell entry datum
  ref: byondRef;
  // Whether the spell requires wizard clothing to cast
  requires_magician_focus: BooleanLike;
  // Spell points required to buy the spell
  cost: number;
  // How many times the spell has been bought
  times: number;
  // Cooldown length of the spell once cast once
  cooldown: number;
  // Whether the spell is refundable
  limit: number;
};

type Data = {
  owner: string;
  entries: SpellEntry[];
};

const categoryTabs = [
  { key: 'Core', icon: 'book', title: 'Core' },
  { key: 'Vanish', icon: 'ghost', title: 'Vanish' },
  { key: 'Production', icon: 'mortar-board', title: 'Production' },
  { key: 'Transformation', icon: 'fish', title: 'Transformation' },
  { key: 'Restoration', icon: 'hand', title: 'Restoration' },
  { key: 'Prestidigitation', icon: 'chess-king', title: 'Prestidigitation' },
  { key: 'Illusion', icon: 'magic', title: 'Illusion' },
  { key: 'Conjuration', icon: 'hat-wizard', title: 'Conjuration' },
];

export const MagicianBook = (props) => {
  const { act, data } = useBackend<MagicianBookData>();
  const [tab, setTab] = useState('Core');
  const introText = [
    'As a stage magician, you must never reveal the secrets behind your tricks.',
    'The art of magic relies on mystery and wonder.',
    'Remember, your magic is meant to entertain and inspire—not to deceive for personal gain or to cause harm.',
    'Always use your skills responsibly and never employ them for malicious or unethical purposes.',
    'To gain more knowledge of magic, you must sacrifice dead mice to the Wand of Something.',
  ];

  const magicianLevels = ['NOVICE', 'APPRENTICE', 'JOURNEYMAN', 'EXPERT', 'MASTER'];

  const currentLevelIndex = magicianLevels.indexOf(data.magician_level || 'NOVICE');

  const nextLevelXP = data.magician_xp_to_next || 10;
  const currentXP = data.magician_xp || 0;
  const progressPercent = Math.min((currentXP / nextLevelXP) * 100, 100);

  // Helper to get rainbow color based on time and index
  const getRainbowColor = (idx) => {
    const now = Date.now();
    // Each line offset by idx*0.2
    const hue = (now / 20 + idx * 40) % 360;
    return `hsl(${hue}, 80%, 60%)`;
  };

  // Force re-render every 50ms for animation
  const [, setTick] = useState(0);
  React.useEffect(() => {
    const interval = setInterval(() => setTick((tick) => tick + 1), 50);
    return () => clearInterval(interval);
  }, []);

  return (
    <Window width={1000} height={500} theme="malfunction">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Box mb={2} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span>
                <b>Current Book Owner:</b> {data.owner || 'no one'}
              </span>
              <span
                style={{
                  fontSize: '25px',
                  fontWeight: 'bold',
                  marginLeft: -100,
                  flex: 1,
                  textAlign: 'center',
                }}>
                The Arts of Stage Magic
              </span>
              <span style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', minWidth: 120 }}>
                <span>
                  <b>Magic Knowledge:</b> {data.magicknowledge ?? '0'}
                </span>
              </span>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Box mb={2} style={{ display: 'flex', justifyContent: 'center' }}>
              <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                {introText.map((line, idx) => (
                  <li
                    key={idx}
                    style={{
                      opacity: 1,
                      transition: 'opacity 0.5s',
                      color: getRainbowColor(idx),
                      marginBottom: 4,
                      fontWeight: idx === introText.length - 1 ? 'bold' : undefined,
                    }}>
                    {line}
                  </li>
                ))}
              </ul>
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab icon="book" selected={tab === 'Core'} onClick={() => setTab('Core')}>
                Core
              </Tabs.Tab>
              <Tabs.Tab icon="ghost" selected={tab === 'Vanish'} onClick={() => setTab('Vanish')}>
                Vanish
              </Tabs.Tab>
              <Tabs.Tab icon="mortar-board" selected={tab === 'Production'} onClick={() => setTab('Production')}>
                Production
              </Tabs.Tab>
              <Tabs.Tab icon="fish" selected={tab === 'Transformation'} onClick={() => setTab('Transformation')}>
                Transformation
              </Tabs.Tab>
              <Tabs.Tab icon="hand" selected={tab === 'Restoration'} onClick={() => setTab('Restoration')}>
                Restoration
              </Tabs.Tab>
              <Tabs.Tab icon="chess-king" selected={tab === 'Prestidigitation'} onClick={() => setTab('Prestidigitation')}>
                Prestidigitation
              </Tabs.Tab>
              <Tabs.Tab icon="magic" selected={tab === 'Illusion'} onClick={() => setTab('Illusion')}>
                Illusion
              </Tabs.Tab>
              <Tabs.Tab icon="hat-wizard" selected={tab === 'Conjuration'} onClick={() => setTab('Conjuration')}>
                Conjuration
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'Placeholder' && (
              <Section title="Placeholder">
                <p>You should not be seeing this.</p>
                {Array.isArray(data.magician_entry) && (
                  <LabeledList>
                    {data.magician_entry
                      .filter((entry) => entry.category?.toLowerCase() === 'core')
                      .map((entry, idx) => (
                        <LabeledList.Item key={idx} label={entry.title || 'Untitled'}>
                          {entry.description || 'No description.'}
                        </LabeledList.Item>
                      ))}
                  </LabeledList>
                )}
              </Section>
            )}

            {categoryTabs.map(
              (tabInfo) =>
                tab === tabInfo.key && (
                  <Section key={tabInfo.key} title={tabInfo.title}>
                    <CategorySection category={tabInfo.key} data={data} act={act} magicknowledge={data.magicknowledge ?? 0} />
                  </Section>
                )
            )}
          </Stack.Item>
          <Stack.Item>
            <Box mb={2} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ color: getRainbowColor(0), fontWeight: 'bold' }}>
                Current Level: {data.magician_level || 'NOVICE'} ({currentLevelIndex + 1}/{magicianLevels.length})
              </span>
              <ProgressBar value={progressPercent} minValue={0} maxValue={100} style={{ width: '60%' }} />
              <span style={{ color: getRainbowColor(1), fontWeight: 'bold' }}>
                <b>XP:</b> {currentXP}/{nextLevelXP}
              </span>
            </Box>
            <Divider />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * Helper to render magician entries by category, with purchase buttons.
 */
const CategorySection = ({
  category,
  data,
  act,
  magicknowledge,
}: {
  category: string;
  data: MagicianBookData;
  act: Function;
  magicknowledge: number;
}) => {
  const entries = Array.isArray(data.magician_entry)
    ? data.magician_entry.filter((entry) => entry.category?.toLowerCase() === category.toLowerCase())
    : [];

  if (!entries.length) {
    return <NoticeBox>No tricks available in this category.</NoticeBox>;
  }

  return (
    <LabeledList>
      {entries.map((entry, idx) => {
        const isLocked = entry.times >= entry.limit;

        return (
          <LabeledList.Item
            key={idx}
            label={<span style={{ color: isLocked ? '#999' : undefined }}>{entry.title || 'Untitled'}</span>}
            buttons={
              <Button
                icon={isLocked ? 'lock' : 'brain'}
                disabled={isLocked || magicknowledge < entry.cost}
                tooltip={
                  isLocked
                    ? 'You have reached the purchase limit for this trick.'
                    : magicknowledge < entry.cost
                      ? 'Not enough Magic Knowledge'
                      : entry.is_spell
                        ? `Learn for ${entry.cost} Magic Knowledge`
                        : `Conjure for ${entry.cost} Magic Knowledge`
                }
                onClick={() => act('purchase', { spellref: entry.ref })}>
                {isLocked ? 'Locked' : `${entry.is_spell ? 'Learn' : 'Conjure'} (${entry.cost ?? 1})`}
              </Button>
            }>
            <span style={{ opacity: isLocked ? 0.5 : 1 }}>{entry.description || 'No description.'}</span>
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};
