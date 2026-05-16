import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs, Tooltip } from 'tgui/components';
import { Window } from 'tgui/layouts';

type Reagent = {
  name: string;
  volume: number;
  overdosed: BooleanLike;
};

type Limb = {
  name: string;
  brute: number;
  burn: number;
  max: number;
  robotic: BooleanLike;
  embedded: string[];
};

type Organ = {
  name: string;
  damage: number;
  max: number;
  status: string;
  robotic: BooleanLike;
};

type Trauma = {
  description: string;
  severity: string;
};

type Disease = {
  name: string;
  stage: number;
  max_stage: number;
  cure: string;
};

type Chem = {
  id: string;
  category: 'Healing' | 'Buff' | 'Debuff';
  goal: string;
  label: string;
  flavor: string;
  description: string;
  warning: string | null;
};

type BooleanLike = 0 | 1 | boolean;

type LeechData = {
  // Leech-side
  substrate: number;
  max_substrate: number;
  chems: Chem[];

  // Host
  host_present: BooleanLike;
  host_name?: string;
  host_dead?: BooleanLike;
  host_health?: number;
  host_max_health?: number;

  brute_loss?: number;
  fire_loss?: number;
  tox_loss?: number;
  oxy_loss?: number;
  clone_loss?: number;
  stamina_loss?: number;

  brain_present?: BooleanLike;
  brain_damage?: number;
  brain_max?: number;

  body_temperature?: number;
  blood_volume?: number;
  blood_normal?: number;
  bleeding?: BooleanLike;
  bleed_rate?: number;

  husked?: BooleanLike;
  cardiac_arrest?: BooleanLike;

  reagents?: Reagent[];
  limbs?: Limb[];
  organs?: Organ[];
  traumas?: Trauma[];
  diseases?: Disease[];
};

export const LeechHostStatus = (_) => {
  const { data } = useBackend<LeechData>();
  const [tab, setTab] = useLocalState('tab', 1);

  const topTabStyle = {
    fontSize: '16px',
    textAlign: 'center',
  } as const;

  return (
    <Window title="Host Status" width={560} height={720}>
      <Window.Content scrollable>
        <Tabs fluid>
          <Tabs.Tab style={topTabStyle} selected={tab === 1} onClick={() => setTab(1)}>
            Vitals
          </Tabs.Tab>
          <Tabs.Tab style={topTabStyle} selected={tab === 2} onClick={() => setTab(2)}>
            Injections
          </Tabs.Tab>
        </Tabs>
        {!data.host_present && (
          <NoticeBox danger mt={1}>
            No host detected. You must be nested inside a host to use this interface.
          </NoticeBox>
        )}
        {tab === 1 && data.host_present && <VitalsPanel />}
        {tab === 2 && <InjectionsPanel />}
      </Window.Content>
    </Window>
  );
};

// --------------------------------------------------------------------------
// VITALS
// --------------------------------------------------------------------------

const damageColor = (val: number, soft = 25, hard = 60) => {
  if (val >= hard) return 'bad';
  if (val >= soft) return 'average';
  if (val > 0) return 'olive';
  return 'good';
};

const VitalsPanel = () => {
  const { data } = useBackend<LeechData>();
  const [vitalsTab, setVitalsTab] = useLocalState('vitalsTab', 'overview');

  return (
    <>
      <CriticalSummary />
      <Tabs mt={1}>
        <Tabs.Tab selected={vitalsTab === 'overview'} onClick={() => setVitalsTab('overview')}>
          Overview
        </Tabs.Tab>
        <Tabs.Tab selected={vitalsTab === 'limbs'} onClick={() => setVitalsTab('limbs')}>
          Limbs
        </Tabs.Tab>
        <Tabs.Tab selected={vitalsTab === 'organs'} onClick={() => setVitalsTab('organs')}>
          Organs
        </Tabs.Tab>
        <Tabs.Tab selected={vitalsTab === 'misc'} onClick={() => setVitalsTab('misc')}>
          Other
        </Tabs.Tab>
      </Tabs>
      {vitalsTab === 'overview' && <OverviewTab />}
      {vitalsTab === 'limbs' && <LimbsTab />}
      {vitalsTab === 'organs' && <OrgansTab />}
      {vitalsTab === 'misc' && <MiscTab />}
    </>
  );
};

const CriticalSummary = () => {
  const { data } = useBackend<LeechData>();
  const {
    host_name,
    host_dead,
    host_health = 0,
    host_max_health = 100,
    reagents = [],
    cardiac_arrest,
    husked,
  } = data;

  return (
    <Section title={`${host_name ?? 'Host'} - Nest Status`}>
      <Stack>
        <Stack.Item grow>
          <ProgressBar
            value={host_health}
            minValue={-100}
            maxValue={host_max_health}
            ranges={{
              good: [host_max_health * 0.5, host_max_health],
              average: [0, host_max_health * 0.5],
              bad: [-100, 0],
            }}
          >
            {host_dead ? 'DECEASED' : `${Math.round(host_health)} / ${host_max_health} HP`}
          </ProgressBar>
        </Stack.Item>
      </Stack>
      {(!!cardiac_arrest || !!husked) && (
        <NoticeBox danger mt={1}>
          {!!cardiac_arrest && <Box>CARDIAC ARREST — heart not beating!</Box>}
          {!!husked && <Box>Subject is husked.</Box>}
        </NoticeBox>
      )}
      <Box mt={1}>
      <DamageBars />
      <Section title="Bloodstream">
        {reagents.length === 0 ? (
          <Box color="label">Bloodstream is clear.</Box>
        ) : (
          <LabeledList>
            {reagents.map((r) => (
              <LabeledList.Item key={r.name} label={r.name}>
                <Box inline color={r.overdosed ? 'bad' : 'white'}>
                  {r.volume}u{!!r.overdosed && ' — OVERDOSING'}
                </Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        )}
      </Section>
      </Box>
    </Section>
  );
};

type MiniBarProps = {
  label: string;
  value: number;
  color: string;
  max?: number;
  missing?: boolean;
};

const MiniDamageBar = (props: MiniBarProps) => {
  const { label, value, color, max = 100, missing } = props;
  if (missing) {
    return (
      <Tooltip content={`${label}: MISSING`}>
        <Box
          height="20px"
          textAlign="center"
          style={{
            backgroundColor: '#000',
            border: '1px solid #ff3333',
            borderRadius: '6px',
            color: '#ff3333',
            fontSize: '11px',
            lineHeight: '18px',
            fontWeight: 'bold',
          }}
        >
          X
        </Box>
      </Tooltip>
    );
  }
  const display = Math.round(value);
  // Pick text color: light backgrounds get black, dark backgrounds get white.
  return (
    <Tooltip content={`${label}: ${display} / ${max}`}>
      <Box
        height="20px"
        textAlign="center"
        style={{
          backgroundColor: color,
          border: '1px solid #111',
          borderRadius: '6px',
          color: '#fff',
          textShadow: '0 0 3px #000, 0 0 3px #000',
          fontWeight: 'bold',
          fontSize: '11px',
          lineHeight: '18px',
        }}
      >
        {display}
      </Box>
    </Tooltip>
  );
};

const DamageBars = () => {
  const { data } = useBackend<LeechData>();
  const {
    brute_loss = 0,
    fire_loss = 0,
    tox_loss = 0,
    oxy_loss = 0,
    clone_loss = 0,
    stamina_loss = 0,
    brain_damage = 0,
    brain_max = 200,
    brain_present,
  } = data;

  const bars: MiniBarProps[] = [
    { label: 'Brute Damage', value: brute_loss, color: '#c0392b' },
    { label: 'Burn Damage', value: fire_loss, color: '#e67e22' },
    { label: 'Toxin Damage', value: tox_loss, color: '#27ae60' },
    { label: 'Suffocation', value: oxy_loss, color: '#2980b9' },
    { label: 'Cellular Damage', value: clone_loss, color: '#8e44ad' },
    { label: 'Stamina Damage', value: stamina_loss, color: '#bac220ff' },
    {
      label: 'Brain Damage',
      value: brain_damage,
      max: brain_max,
      color: '#d63384',
      missing: !brain_present,
    },
  ];

  return (
    <Box mb={1}>
      <Stack fill>
        {bars.map((bar, i) => (
          <Stack.Item key={i} grow basis={0}>
            <MiniDamageBar {...bar} />
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

const OverviewTab = () => {
  const { data } = useBackend<LeechData>();
  const {
    body_temperature = 0,
    blood_volume = 0,
    blood_normal = 560,
    bleeding,
    bleed_rate = 0,
    stamina_loss = 0,
  } = data;
  const bloodPct = Math.round((blood_volume / blood_normal) * 100);

  return (
    <Section title="Vital Signs">
      <LabeledList>
        <LabeledList.Item label="Body Temp">{body_temperature}°C</LabeledList.Item>
        <LabeledList.Item label="Blood Volume">
          <Box color={bloodPct < 80 ? (bloodPct < 60 ? 'bad' : 'average') : 'good'}>
            {blood_volume} cl ({bloodPct}%)
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Bleeding">
          {bleeding ? <Box color="bad">YES — {bleed_rate}/s</Box> : <Box color="good">No</Box>}
        </LabeledList.Item>
        <LabeledList.Item label="Stamina Loss">
          <Box color={damageColor(stamina_loss, 40, 80)}>{stamina_loss}</Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const LimbsTab = () => {
  const { data } = useBackend<LeechData>();
  const { limbs = [] } = data;
  return (
    <Section title="Limbs">
      {limbs.length === 0 ? (
        <Box color="label">No limbs reported.</Box>
      ) : (
        <LabeledList>
          {limbs.map((limb) => (
            <LabeledList.Item key={limb.name} label={limb.name}>
              <Box inline mr={2} color={damageColor(limb.brute, limb.max * 0.3, limb.max * 0.7)}>
                Brute: {limb.brute}
              </Box>
              <Box inline mr={2} color={damageColor(limb.burn, limb.max * 0.3, limb.max * 0.7)}>
                Burn: {limb.burn}
              </Box>
              {!!limb.robotic && (
                <Box inline color="label">
                  [Robotic]
                </Box>
              )}
              {limb.embedded.length > 0 && (
                <Box color="bad">Embedded: {limb.embedded.join(', ')}</Box>
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      )}
    </Section>
  );
};

const OrgansTab = () => {
  const { data } = useBackend<LeechData>();
  const { organs = [] } = data;
  return (
    <Section title="Organs">
      {organs.length === 0 ? (
        <Box color="label">No internal organs reported.</Box>
      ) : (
        <LabeledList>
          {organs.map((organ) => {
            const color =
              organ.status === 'FAILING'
                ? 'bad'
                : organ.status === 'Severely Damaged'
                  ? 'average'
                  : organ.status === 'Bruised'
                    ? 'olive'
                    : 'good';
            return (
              <LabeledList.Item key={organ.name} label={organ.name}>
                <Box inline mr={2} color={color}>
                  {organ.status}
                </Box>
                <Box inline color="label">
                  ({organ.damage} / {organ.max}){!!organ.robotic && ' [Robotic]'}
                </Box>
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      )}
    </Section>
  );
};

const MiscTab = () => {
  const { data } = useBackend<LeechData>();
  const { traumas = [], diseases = [] } = data;
  return (
    <>
      <Section title="Brain Traumas">
        {traumas.length === 0 ? (
          <Box color="good">None detected.</Box>
        ) : (
          traumas.map((t, i) => (
            <Box key={i} color="bad">
              [{t.severity}] {t.description}
            </Box>
          ))
        )}
      </Section>
      <Section title="Diseases">
        {diseases.length === 0 ? (
          <Box color="good">None detected.</Box>
        ) : (
          diseases.map((d, i) => (
            <Box key={i} color="bad">
              {d.name} (Stage {d.stage}/{d.max_stage}) — Cure: {d.cure}
            </Box>
          ))
        )}
      </Section>
    </>
  );
};

// --------------------------------------------------------------------------
// INJECTIONS
// --------------------------------------------------------------------------

const INJECT_AMOUNTS = [1, 5, 10, 20, 50];

const CATEGORY_ORDER: Chem['category'][] = ['Healing', 'Buff', 'Debuff'];

const CATEGORY_DESCRIPTIONS: Record<Chem['category'], string> = {
  Healing: 'Repair, restore, or stabilize the host.',
  Buff: 'Empower the host beyond normal limits.',
  Debuff: 'Cripple, paralyze, or otherwise harm the host or anyone they touch.',
};

const InjectionsPanel = () => {
  const { act, data } = useBackend<LeechData>();
  const { chems = [], substrate = 0, max_substrate = 100, host_present } = data;
  const [category, setCategory] = useLocalState<Chem['category']>('inject_cat', 'Healing');
  const [amount, setAmount] = useLocalState('inject_amount', 10);

  const filtered = chems.filter((c) => c.category === category);

  return (
    <>
      <Section title="Substrate Reservoir">
        <ProgressBar
          value={substrate}
          maxValue={max_substrate}
          ranges={{
            good: [max_substrate * 0.5, max_substrate],
            average: [max_substrate * 0.2, max_substrate * 0.5],
            bad: [0, max_substrate * 0.2],
          }}
        >
          {substrate} / {max_substrate} substrate
        </ProgressBar>
        <Box mt={1} color="label">
          Substrate is consumed 1:1 with units injected. Choose a goal first, then a dose.
        </Box>
      </Section>

      <Section title="Dose">
        {INJECT_AMOUNTS.map((a) => (
          <Button
            key={a}
            selected={amount === a}
            onClick={() => setAmount(a)}
            content={`${a}u`}
          />
        ))}
        <Box mt={1} color="label">
          Selected dose: <b>{amount} units</b>
          {amount > substrate && (
            <Box inline color="bad">
              {' '}
              — only {substrate}u will be injected (substrate limit)
            </Box>
          )}
        </Box>
      </Section>

      <Section title="What do you want to do?">
        <Tabs>
          {CATEGORY_ORDER.map((cat) => (
            <Tabs.Tab key={cat} selected={category === cat} onClick={() => setCategory(cat)}>
              {cat}
            </Tabs.Tab>
          ))}
        </Tabs>
        <Box mt={1} mb={1} color="label">
          {CATEGORY_DESCRIPTIONS[category]}
        </Box>
        {!host_present && (
          <NoticeBox danger>You must be nested in a host to inject.</NoticeBox>
        )}
        <Stack vertical>
          {filtered.map((chem) => (
            <Stack.Item key={chem.id}>
              <Section
                title={chem.goal}
                buttons={
                  <Button
                    icon="syringe"
                    color="good"
                    disabled={!host_present || substrate <= 0}
                    onClick={() => act('inject', { id: chem.id, amount })}
                  >
                    Inject {Math.min(amount, substrate)}u
                  </Button>
                }
              >
                <Box bold>{chem.label}</Box>
                <Box color="label" italic>
                  ({chem.flavor})
                </Box>
                <Box mt={1}>{chem.description}</Box>
                {!!chem.warning && (
                  <Box mt={1} color="bad">
                    ⚠ {chem.warning}
                  </Box>
                )}
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </>
  );
};
