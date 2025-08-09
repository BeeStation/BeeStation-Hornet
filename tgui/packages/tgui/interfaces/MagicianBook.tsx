import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Divider, NoticeBox, ProgressBar, Section, Stack, Tabs, LabeledList } from '../components';
import { Window } from '../layouts';
import { ReactNode, useState, useEffect } from 'react';

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
    ref: string; // Changed from byondRef to string
    times: number;
    cooldown: number;
    requires_magician_focus: BooleanLike;
    limit: number;
    is_spell?: boolean;
  }>;
};

type SpellEntry = {
  name: string;
  desc: string;
  ref: string;
  requires_magician_focus: BooleanLike;
  cost: number;
  times: number;
  cooldown: number;
  limit: number;
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
  const [tick, setTick] = useState(0); // Added tick state

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

  const getRainbowColor = (idx: number) => {
    const now = Date.now();
    const hue = (now / 20 + idx * 40) % 360;
    return `hsl(${hue}, 80%, 60%)`;
  };

  useEffect(() => {
    const interval = setInterval(() => setTick((t) => t + 1), 50);
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
              {categoryTabs.map((tabInfo) => (
                <Tabs.Tab
                  key={tabInfo.key}
                  icon={tabInfo.icon}
                  selected={tab === tabInfo.key}
                  onClick={() => setTab(tabInfo.key)}>
                  {tabInfo.title}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
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

type CategorySectionProps = {
  category: string;
  data: MagicianBookData;
  act: Function;
  magicknowledge: number;
};

const CategorySection = ({ category, data, act, magicknowledge }: CategorySectionProps) => {
  const entries = Array.isArray(data.magician_entry)
    ? data.magician_entry.filter((entry) => entry.category?.toLowerCase() === category.toLowerCase())
    : [];

  if (!entries.length) {
    return <NoticeBox>No tricks available in this category.</NoticeBox>;
  }

  return (
    <LabeledList>
      {entries.map((entry, idx) => {
        const isSpell = entry.is_spell === true;
        const isLocked = entry.times >= entry.limit;
        const cost = entry.cost ?? 1;

        return (
          <LabeledList.Item
            key={idx}
            label={<span style={{ color: isLocked ? '#999' : undefined }}>{entry.title || 'Untitled'}</span>}
            buttons={
              <Button
                icon={isLocked ? 'lock' : isSpell ? 'brain' : 'brain'}
                disabled={isLocked || magicknowledge < cost}
                tooltip={
                  isLocked
                    ? 'You have reached the purchase limit for this trick.'
                    : magicknowledge < cost
                      ? 'Not enough Magic Knowledge'
                      : isSpell
                        ? `Upgrade for ${cost} Magic Knowledge`
                        : `Conjure for ${cost} Magic Knowledge`
                }
                onClick={() => act('purchase', { spellref: entry.ref })}>
                {isLocked ? 'Locked' : isSpell ? `Learn (${cost})` : `Conjure (${cost})`}
              </Button>
            }>
            <span style={{ opacity: isLocked ? 0.5 : 1 }}>
              {entry.description || 'No description.'}
              {isSpell && entry.times > 0 && (
                <span style={{ display: 'block', fontSize: '0.8em', color: '#aaa' }}>Level: {entry.times}</span>
              )}
            </span>
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};
