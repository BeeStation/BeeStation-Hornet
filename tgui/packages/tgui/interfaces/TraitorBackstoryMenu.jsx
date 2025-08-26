import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { AntagInfoTraitorContent } from './AntagInfoTraitor';

export const TraitorBackstoryMenu = (_) => {
  const { data } = useBackend();
  const { all_backstories = {}, all_factions = {}, backstory, faction } = data;
  let has_backstory = all_backstories[backstory];
  let has_faction = all_factions[faction];
  let [ui_phase, set_ui_phase] = useLocalState(
    'traitor_ui_phase',
    has_faction ? 2 : 0,
  );
  let [tabIndex, setTabIndex] = useLocalState('traitor_selected_tab', 1);
  let [selected_faction, set_selected_faction_backend] = useLocalState(
    'traitor_selected_faction',
    'syndicate',
  );
  let [selected_backstory, set_selected_backstory] = useLocalState(
    'traitor_selected_backstory',
    null,
  );
  const set_selected_faction = (faction) => {
    set_selected_faction_backend(faction);
    if (
      selected_backstory &&
      !all_backstories[selected_backstory].allowed_factions?.includes(faction)
    ) {
      set_selected_backstory(null);
    }
  };
  let windowTitle = 'Traitor Backstory';
  switch (ui_phase) {
    case 0:
      windowTitle = 'Traitor Backstory: Introduction';
      break;
    case 1:
      windowTitle = 'Traitor Backstory: Faction Select';
      break;
    case 2:
      windowTitle = tabIndex === 1 ? 'Traitor Info' : 'Traitor Backstory';
      break;
  }
  let info_ui = ui_phase === 2 && has_faction;
  return (
    <Window
      theme={faction === 'syndicate' ? 'syndicate' : 'neutral'}
      width={650}
      height={info_ui ? 650 : 500}
      title={windowTitle}
    >
      <Window.Content scrollable>
        {ui_phase === 0 && <IntroductionMenu set_ui_phase={set_ui_phase} />}
        {ui_phase === 1 && (
          <SelectFactionMenu
            set_ui_phase={set_ui_phase}
            selected_faction={selected_faction}
            set_selected_faction={set_selected_faction}
          />
        )}
        {ui_phase === 2 && !has_faction && (
          <SelectBackstoryMenu
            set_ui_phase={set_ui_phase}
            selected_faction={selected_faction}
            set_selected_faction={set_selected_faction}
            selected_backstory={selected_backstory}
            set_selected_backstory={set_selected_backstory}
            show_nav
          />
        )}
        {ui_phase === 2 && has_faction && (
          <>
            <Tabs p={1} pb={0.25}>
              <Button
                mr={1}
                fontSize="15px"
                color="bad"
                icon="arrow-left"
                content="Back"
                onClick={() => {
                  set_ui_phase((phase) => phase - 1);
                }}
              />
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                Antagonist Info
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                Backstory
              </Tabs.Tab>
            </Tabs>
            <Box height="calc(100vh - 90px)">
              {tabIndex === 1 ? (
                <AntagInfoTraitorContent />
              ) : has_backstory ? (
                <BackstoryDetails />
              ) : (
                <SelectBackstoryMenu
                  set_ui_phase={set_ui_phase}
                  selected_faction={selected_faction}
                  set_selected_faction={set_selected_faction}
                  selected_backstory={selected_backstory}
                  set_selected_backstory={set_selected_backstory}
                />
              )}
            </Box>
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const IntroductionMenu = ({ set_ui_phase }) => {
  const { act, data } = useBackend();
  const { faction } = data;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <Stack.Item fontSize="28px" mb={5} maxWidth="80vw">
              Traitor Backstory Generator
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              This menu is a tool for you to use as an antagonist, giving a
              foundation for your character&apos;s motivations and reasoning for
              being a traitor.
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              Please <strong>select a faction</strong> - a short description of
              each will be given. You will <strong>not</strong> be able to
              change this after your main backstory is locked in, so choose
              wisely.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            mt={2}
            fontSize="15px"
            color="good"
            content="Continue"
            onClick={() => {
              set_ui_phase((phase) => phase + 1);
            }}
          />
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const get_surrounding_factions = (faction_keys, selected_faction) => {
  let max_index = faction_keys.length - 1;
  let current_index = faction_keys.indexOf(selected_faction);
  let next_faction = current_index + 1;
  let prev_faction = current_index - 1;
  if (next_faction > max_index) {
    next_faction = 0;
  }
  if (prev_faction < 0) {
    prev_faction = max_index;
  }
  next_faction = faction_keys[next_faction];
  prev_faction = faction_keys[prev_faction];
  return [prev_faction, next_faction];
};

const SelectFactionMenu = ({
  set_ui_phase,
  set_selected_faction,
  selected_faction,
}) => {
  const { data } = useBackend();
  const {
    allowed_factions = [],
    all_factions = {},
    faction,
    recommended_factions = [],
  } = data;
  let faction_keys = Object.keys(all_factions);

  if (
    faction_keys.length === 0 ||
    faction_keys.filter((key) => allowed_factions.includes(key)).length === 0
  ) {
    return (
      <Dimmer>
        No valid factions found. This is likely a bug. Please reload or reopen
        the menu.
      </Dimmer>
    );
  }

  let current_faction = all_factions[faction] || all_factions[selected_faction];
  let current_faction_key = faction || selected_faction;

  return (
    <Dimmer>
      <Box
        width="100%"
        textAlign="center"
        fontSize="25px"
        pb={0.75}
        style={{
          position: 'absolute',
          left: '50%',
          top: '8px',
          transform: 'translateX(-50%)',
          borderBottom: '1px solid #aa2a2a',
        }}
      >
        <strong>Faction Select</strong>
      </Box>
      <Button
        fontSize="15px"
        color="bad"
        icon="arrow-left"
        content="Back"
        style={{ position: 'absolute', left: '8px', top: '8px' }}
        onClick={() => {
          set_ui_phase((phase) => phase - 1);
        }}
      />
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <BackstoryInfo data={current_faction} />
          </Stack>
        </Stack.Item>
        <Stack.Item>
          {faction ? (
            <Button
              mt={2}
              fontSize="15px"
              content="Continue"
              color="good"
              onClick={() => {
                set_ui_phase((phase) => phase + 1);
              }}
            />
          ) : allowed_factions.includes(current_faction_key) &&
            recommended_factions.length !== 0 &&
            !recommended_factions.includes(current_faction_key) ? (
            <Button.Confirm
              mt={2}
              fontSize="15px"
              color="bad"
              content="Select"
              tooltip={
                'This faction is NOT recommended based on your current objectives.'
              }
              onClick={() => {
                set_ui_phase((phase) => phase + 1);
              }}
            />
          ) : (
            <Button
              mt={2}
              fontSize="15px"
              color={recommended_factions.length === 0 ? null : 'good'}
              content="Select"
              disable={!allowed_factions.includes(current_faction_key)}
              tooltip={
                !allowed_factions.includes(current_faction_key)
                  ? 'You are not able to select this faction.'
                  : recommended_factions.length === 0
                    ? null
                    : 'This faction is recommended based on your current objectives'
              }
              onClick={() => {
                set_ui_phase((phase) => phase + 1);
              }}
            />
          )}
        </Stack.Item>
        {(recommended_factions.length > 0 || faction) && (
          <Stack.Item
            mt={3}
            textColor={
              faction
                ? 'red'
                : recommended_factions.includes(current_faction_key)
                  ? 'green'
                  : 'red'
            }
          >
            <strong>
              {faction
                ? 'Your faction is locked in.'
                : recommended_factions.includes(current_faction_key)
                  ? 'This faction is recommended based on your current objectives.'
                  : 'This faction is NOT recommended based on your current objectives.'}
            </strong>
          </Stack.Item>
        )}
      </Stack>
      {!faction && (
        <FactionNavigationButtons
          faction_keys={faction_keys}
          selected_faction={selected_faction}
          set_selected_faction={set_selected_faction}
          left="8px"
          right="8px"
          top="45%"
          size="18px"
        />
      )}
    </Dimmer>
  );
};

const FactionNavigationButtons = (
  {
    faction_keys,
    selected_faction,
    left,
    right,
    top,
    size,
    set_selected_faction,
  },
  _,
) => {
  let [prev_faction, next_faction] = get_surrounding_factions(
    faction_keys,
    selected_faction,
  );
  return (
    <>
      <Button
        fontSize={size}
        icon="arrow-left"
        style={{ position: 'absolute', left: left, top: top }}
        onClick={() => set_selected_faction(prev_faction)}
      />
      <Button
        fontSize={size}
        icon="arrow-right"
        style={{ position: 'absolute', right: right, top: top }}
        onClick={() => set_selected_faction(next_faction)}
      />
    </>
  );
};

const BackstoryInfo = ({ data, titleColor }) => {
  return (
    <>
      <Stack.Item fontSize="28px" mb={2} maxWidth="80vw" textColor={titleColor}>
        {data?.name}
      </Stack.Item>
      {data?.description?.split('\n').map((value, index) => (
        <Stack.Item
          key={'desc-' + index}
          maxWidth="70vw"
          dangerouslySetInnerHTML={{
            __html: value,
          }}
        />
      ))}
    </>
  );
};

const MOTIVATION_ICONS = {
  'Forced Into It': 'user-alt-slash',
  'Not Forced Into It': 'user-check',
  Money: 'dollar-sign',
  Political: 'peace',
  Love: 'heart',
  Reputation: 'comments-dollar',
  'Death Threat': 'skull',
  Authority: 'users',
  Fun: 'grin-tongue-wink',
};

const SelectBackstoryMenu = ({
  set_ui_phase,
  selected_faction,
  set_selected_faction,
  selected_backstory,
  set_selected_backstory,
  show_nav,
}) => {
  const { act, data } = useBackend();
  const {
    allowed_backstories = [],
    all_backstories = {},
    recommended_backstories = [],
    all_motivations = [],
    all_factions = {},
    allowed_factions = [],
    faction,
    backstory,
  } = data;

  let [motivations, set_motivations] = useLocalState('traitor_motivations', []);

  const toggle_motivation = (name) =>
    set_motivations((motivations) => {
      if (motivations.includes(name)) {
        let index = motivations.indexOf(name);
        if (index > -1) {
          motivations.splice(index, 1);
        }
      } else {
        if (
          name === 'Not Forced Into It' &&
          motivations.includes('Forced Into It')
        ) {
          toggle_motivation('Forced Into It');
        }
        if (
          name === 'Forced Into It' &&
          motivations.includes('Not Forced Into It')
        ) {
          toggle_motivation('Not Forced Into It');
        }
        motivations.push(name);
      }
      return motivations;
    });

  let current_faction = all_factions[faction] || all_factions[selected_faction];
  let current_faction_key = faction || selected_faction;

  let allowed_backstories_filtered = Object.values(all_backstories)
    .filter(
      (value) =>
        value.allowed_factions?.includes(current_faction_key) &&
        allowed_backstories.includes(value.path),
    )
    .map((value) => value.path);
  if (allowed_backstories_filtered.length === 0) {
    return (
      <Dimmer>
        No valid backstories found. This is likely a bug. Please reload or
        reopen the menu.
      </Dimmer>
    );
  }

  let current_backstory =
    all_backstories[backstory] || all_backstories[selected_backstory];
  let current_backstory_key = backstory || selected_backstory;

  return (
    <Flex height="100%" direction="column">
      <Flex.Item mb={1}>
        <Section
          fill
          title={
            <>
              <Box width="100%" textAlign="center" fontSize="20px">
                {!faction && (
                  <FactionNavigationButtons
                    faction_keys={Object.keys(all_factions).filter((v) =>
                      allowed_factions.includes(v),
                    )}
                    selected_faction={current_faction_key}
                    set_selected_faction={set_selected_faction}
                    left="28%"
                    right="28%"
                    top="8px"
                    size="13px"
                  />
                )}
                <strong>{current_faction.name}</strong>
              </Box>
              {show_nav && (
                <Button
                  fontSize="15px"
                  color="bad"
                  icon="arrow-left"
                  content="Back"
                  style={{ position: 'absolute', left: '5px', top: '5px' }}
                  onClick={() => {
                    set_ui_phase((phase) => phase - 1);
                  }}
                />
              )}
            </>
          }
        >
          <Box mb={0.5}>
            <strong>What motivates your character?</strong>
          </Box>
          {all_motivations.map((motivation) => (
            <Button.Checkbox
              key={motivation + '-checkbox'}
              icon={
                motivations?.includes(motivation)
                  ? MOTIVATION_ICONS[motivation]
                  : 'square-o'
              }
              content={motivation}
              onClick={() => toggle_motivation(motivation)}
              checked={motivations?.includes(motivation)}
            />
          ))}
        </Section>
      </Flex.Item>
      {/* Don't ask me why height: 0 somehow fixes the flow layout scrollability, but it does. */}
      <Flex.Item grow height="0">
        <Flex height="100%">
          <Flex.Item minWidth="180px">
            <Box
              height="100%"
              width="100%"
              className="Section Section-fill"
              style={{
                padding: '0.66em 0.5em',
                'overflow-y': 'scroll',
                direction: 'rtl',
              }}
            >
              <Tabs vertical style={{ direction: 'ltr' }} textAlign="right">
                {Object.values(all_backstories)
                  .filter((v) => allowed_backstories_filtered?.includes(v.path))
                  .map((backstory) => (
                    <BackstoryTab
                      path={backstory.path}
                      key={backstory.path}
                      name={backstory.name}
                      selected={current_backstory_key === backstory.path}
                      set_selected_backstory={set_selected_backstory}
                      is_recommended_objectives={recommended_backstories.includes(
                        backstory.path,
                      )}
                      recommendation_count={
                        backstory.motivations.filter((r) =>
                          motivations?.includes(r),
                        ).length
                      }
                      matches_all_recommendations={
                        motivations.filter(
                          (r) => !backstory.motivations?.includes(r),
                        ).length === 0
                      }
                    />
                  ))}
              </Tabs>
            </Box>
          </Flex.Item>
          <Flex.Item grow basis={0} ml={1}>
            {current_backstory ? (
              <BackstorySection
                show_button
                fill
                backstory={current_backstory}
                backstory_locked={!!backstory}
                backstory_key={selected_backstory}
                faction_key={current_faction_key}
                set_ui_phase={set_ui_phase}
              />
            ) : (
              <Section fill>
                <Dimmer>No backstory selected</Dimmer>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const BackstorySection = ({
  backstory,
  backstory_locked,
  show_button,
  backstory_key,
  faction_key,
  set_ui_phase,
  fill,
}) => {
  const { act } = useBackend();
  return (
    <Section
      fill={fill}
      title={
        <Box inline fontSize={1.8}>
          {backstory.name}
        </Box>
      }
      fontSize={1.25}
      buttons={
        <>
          {Object.entries(MOTIVATION_ICONS)
            .filter(([k, v]) => backstory.motivations?.includes(k))
            .map(([motivation, icon]) => (
              <Tooltip
                key={'icon-motivation-tooltip-' + motivation}
                content={motivation}
              >
                <Icon
                  fontSize={1.75}
                  key={'icon-motivation-' + motivation}
                  mr={1}
                  mt={1}
                  pr={0.5}
                  pl={0.5}
                  name={icon}
                />
              </Tooltip>
            ))}
          {show_button ? (
            backstory_locked ? (
              <Button
                fontSize={1.4}
                style={{ transform: 'translateY(-2.5px)' }}
                content="Continue"
                color="good"
                onClick={() => set_ui_phase((phase) => phase + 1)}
              />
            ) : (
              <Button.Confirm
                fontSize={1.4}
                style={{ transform: 'translateY(-2.5px)' }}
                confirmContent="Lock In?"
                tooltip="You won't be able to change this selection after locking it in."
                content="Select"
                onClick={() =>
                  act('select_backstory', {
                    faction: faction_key,
                    backstory: backstory_key,
                  })
                }
              />
            )
          ) : null}
        </>
      }
    >
      <Box inline dangerouslySetInnerHTML={{ __html: backstory.description }} />
    </Section>
  );
};

const BackstoryTab = ({
  path,
  name,
  selected,
  is_recommended_objectives,
  recommendation_count,
  matches_all_recommendations,
  set_selected_backstory,
}) => {
  return (
    <Tabs.Tab
      fontSize={1.05}
      selected={selected}
      onClick={() => set_selected_backstory(selected ? null : path)}
    >
      {name}
      {is_recommended_objectives && (
        <Tooltip content="This backstory is recommended due to your murderbone status.">
          <Icon name="crosshairs" color="red" fontSize={1} ml={1} />
        </Tooltip>
      )}
      {recommendation_count > 0 && (
        <Tooltip content="This backstory is recommended based on your motivations.">
          <Icon
            fontSize={1.25}
            name="star"
            color={
              matches_all_recommendations
                ? 'yellow'
                : recommendation_count > 1
                  ? 'silver'
                  : 'brown'
            }
            ml={1}
          />
          <Box
            inline
            width="0"
            color="black"
            fontSize={1}
            style={{ transform: 'translate(-12px, -1px)' }}
          >
            {recommendation_count}
          </Box>
        </Tooltip>
      )}
    </Tabs.Tab>
  );
};

const BackstoryDetails = (_) => {
  const { data } = useBackend();
  const { backstory, all_backstories = {} } = data;
  return <BackstorySection fill backstory={all_backstories[backstory]} />;
};
