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

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: boolean;
};

type Backstory = {
  name: string;
  description: string;
  path: string;
  motivations: string[];
};

type TraitorBackstoryStaticData = {
  all_backstories: Backstory[];
  all_motivations: string[];
};

type TraitorBackstoryData = {
  allowed_backstories: string[];
  recommended_backstories: string[];
  backstory: string | undefined;
  antag_name: string;
  code: string | undefined;
  failsafe_code: string | undefined;
  has_uplink: boolean;
  uplink_unlock_info: string | undefined;
  objectives: Objective[];
} & (
  | {
      has_codewords: true;
      phrases: string;
      responses: string;
    }
  | {
      has_codewords: false;
    }
) &
  TraitorBackstoryStaticData;

export const TraitorBackstoryMenu = () => {
  const { data } = useBackend<TraitorBackstoryData>();
  const { all_backstories = {}, backstory } = data;
  let has_backstory = backstory && all_backstories[backstory];
  let [ui_phase, set_ui_phase] = useLocalState(
    'traitor_ui_phase',
    has_backstory ? 1 : 0,
  );
  let [tabIndex, setTabIndex] = useLocalState('traitor_selected_tab', 1);
  let [selected_backstory, set_selected_backstory] = useLocalState(
    'traitor_selected_backstory',
    null,
  );
  let windowTitle = 'Traitor Backstory';
  switch (ui_phase) {
    case 0:
      windowTitle = 'Traitor Backstory: Introduction';
      break;
    case 1:
      windowTitle = tabIndex === 1 ? 'Traitor Info' : 'Traitor Backstory';
      break;
  }
  let info_ui = ui_phase === 1;
  return (
    <Window
      theme={'syndicate'}
      width={650}
      height={info_ui ? 650 : 500}
      title={windowTitle}
    >
      <Window.Content scrollable>
        {ui_phase === 0 && <IntroductionMenu set_ui_phase={set_ui_phase} />}
        {ui_phase === 1 && !has_backstory && (
          <SelectBackstoryMenu
            set_ui_phase={set_ui_phase}
            selected_backstory={selected_backstory}
            set_selected_backstory={set_selected_backstory}
            show_nav
          />
        )}
        {ui_phase === 1 && has_backstory && (
          <>
            <Tabs p={1} pb={0.25}>
              <Button
                mr={1}
                fontSize="15px"
                color="bad"
                icon="arrow-left"
                content="Back"
                onClick={() => {
                  set_ui_phase(ui_phase - 1);
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
  const { act, data } = useBackend<TraitorBackstoryData>();
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
              Please <strong>select a backstory</strong> - a short description
              of each will be given. You will <strong>not</strong> be able to
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
  selected_backstory,
  set_selected_backstory,
  show_nav = false,
}) => {
  const { act, data } = useBackend<TraitorBackstoryData>();
  const {
    allowed_backstories = [],
    all_backstories = [],
    recommended_backstories = [],
    all_motivations = [],
    backstory,
  } = data;

  let [motivations, set_motivations] = useLocalState<string[]>(
    'traitor_motivations',
    [],
  );

  const nextMotivation = (name: string, motivations: string[]) => {
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
  };

  const toggle_motivation = (name: string) =>
    set_motivations(nextMotivation(name, motivations));

  let allowed_backstories_filtered = Object.values(all_backstories)
    .filter((value) => allowed_backstories.includes(value.path))
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
    (backstory && all_backstories[backstory]) ||
    all_backstories[selected_backstory];
  let current_backstory_key = backstory || selected_backstory;

  return (
    <Flex height="100%" direction="column">
      <Flex.Item mb={1}>
        <Section
          fill
          title={
            <>
              <Box width="100%" textAlign="center" fontSize="20px">
                <strong>The Syndicate</strong>
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
  set_ui_phase,
  fill,
}) => {
  const { act } = useBackend<TraitorBackstoryData>();
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
  key = '',
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
  const { data } = useBackend<TraitorBackstoryData>();
  const { backstory, all_backstories = {} } = data;
  return (
    <BackstorySection
      fill
      backstory={backstory && all_backstories[backstory]}
      backstory_locked={false}
      show_button={false}
      backstory_key={backstory}
      set_ui_phase={undefined}
    />
  );
};
