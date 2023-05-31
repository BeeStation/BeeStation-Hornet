import { useBackend, useLocalState } from '../backend';
import { Button, Dimmer, Stack, Box } from '../components';
import { Window } from '../layouts';

export const TraitorObjectivesMenu = (props, context) => {
  const { act, data } = useBackend(context);
  let [ui_phase, set_ui_phase] = useLocalState(context, "traitor_ui_phase", 0);
  let [selected_faction, set_selected_faction] = useLocalState(context, "traitor_selected_faction", "syndicate");
  let ui_to_show = null;
  switch (ui_phase) {
    case 0:
      ui_to_show = <IntroductionMenu set_ui_phase={set_ui_phase} />;
      break;
    case 1:
      ui_to_show = (<SelectFactionMenu
        set_ui_phase={set_ui_phase}
        selected_faction={selected_faction}
        set_selected_faction={set_selected_faction} />);
      break;
    case 2:
      ui_to_show = (<SelectBackstoryMenu
        set_ui_phase={set_ui_phase}
        selected_faction={selected_faction} />);
  }
  return (
    <Window theme="neutral" width={650} height={500}>
      <Window.Content scrollable>
        {ui_to_show}
      </Window.Content>
    </Window>
  );
};

const IntroductionMenu = ({ set_ui_phase }, context) => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <Stack.Item fontSize="28px" mb={5} maxWidth="80vw">
              Traitor Objective Backstory Generator
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              This menu is a tool for you to use as an antagonist,
              giving a foundation for your character&apos;s motivations and reasoning for being a traitor.
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              As such, it&apos;s not required that you use it, but you would be doing a disservice to your fellow players.
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              Please <strong>select a faction</strong> - a short description of each will be given.
              You will <strong>not</strong> be able to change this after your main backstory is locked in, so choose wisely.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                mt={2}
                fontSize="15px"
                color="good"
                content="Continue"
                onClick={() => {
                  set_ui_phase(phase => phase + 1);
                }} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const SelectFactionMenu = ({ set_ui_phase, set_selected_faction, selected_faction }, context) => {
  const { act, data } = useBackend(context);
  const {
    allowed_factions = [],
    all_factions = {
      "syndicate": {},
    },
  } = data;
  let faction_keys = Object.keys(all_factions);
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
  let faction = all_factions[selected_faction];

  return (
    <Dimmer>
      <Box
        width="100%"
        textAlign="center"
        fontSize="25px"
        pb={0.75}
        style={{ position: "absolute", left: "50%", top: "8px", transform: "translateX(-50%)", "border-bottom": "1px solid #aa2a2a" }}>
        <strong>Faction Select</strong>
      </Box>
      <Button
        fontSize="15px"
        color="bad"
        icon="arrow-left"
        content="Back"
        style={{ position: "absolute", left: "8px", top: "8px" }}
        onClick={() => {
          set_ui_phase(phase => phase - 1);
        }} />
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <BackstoryInfo data={faction} />
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                mt={2}
                fontSize="15px"
                color="good"
                content="Select"
                onClick={() => {
                  set_ui_phase(phase => phase + 1);
                }} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Button
        fontSize="18px"
        icon="arrow-left"
        style={{ position: "absolute", left: "8px", top: "45%" }}
        onClick={() => set_selected_faction(prev_faction)} />
      <Button
        fontSize="18px"
        icon="arrow-right"
        iconPosition="right"
        style={{ position: "absolute", right: "8px", top: "45%" }}
        onClick={() => set_selected_faction(next_faction)} />
    </Dimmer>
  );
};

const BackstoryInfo = ({ data }, context) => {
  return (
    <>
      <Stack.Item fontSize="28px" mb={2} maxWidth="80vw">
        {data?.name}
      </Stack.Item>
      {data?.description?.split("\n").map((value, index) => (
        <Stack.Item key={"desc-" + index} maxWidth="70vw" dangerouslySetInnerHTML={{
          __html: value,
        }} />
      ))}

    </>
  );
};

const SelectBackstoryMenu = ({ set_ui_phase, set_selected_faction, selected_faction }, context) => {
  const { act, data } = useBackend(context);
  const {
    allowed_backstories = [],
    all_backstories = {},
  } = data;
  let backstory_keys = Object.keys(all_backstories);
  let [selected_backstory, set_selected_backstory] = useLocalState(context, "traitor_selected_backstory", backstory_keys[0]);
  let max_index = backstory_keys.length - 1;
  let current_index = backstory_keys.indexOf(selected_backstory);
  let next_backstory = current_index + 1;
  let prev_backstory = current_index - 1;
  if (next_backstory > max_index) {
    next_backstory = 0;
  }
  if (prev_backstory < 0) {
    prev_backstory = max_index;
  }
  next_backstory = backstory_keys[next_backstory];
  prev_backstory = backstory_keys[prev_backstory];
  let backstory = all_backstories[selected_backstory];

  return (
    <Dimmer>
      <Box
        width="100%"
        textAlign="center"
        fontSize="25px"
        pb={0.75}
        style={{ position: "absolute", left: "50%", top: "8px", transform: "translateX(-50%)", "border-bottom": "1px solid #aa2a2a" }}>
        <strong>Backstory Select</strong>
      </Box>
      <Button
        fontSize="15px"
        color="bad"
        icon="arrow-left"
        content="Back"
        style={{ position: "absolute", left: "8px", top: "8px" }}
        onClick={() => {
          set_ui_phase(phase => phase - 1);
        }} />
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <BackstoryInfo data={backstory} />
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button.Confirm
                mt={2}
                fontSize="15px"
                confirm
                icon="lock-open"
                color="good"
                confirmIcon="lock"
                content="Select"
                onClick={() => {
                  set_ui_phase(phase => phase + 1);
                }} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Button
        fontSize="18px"
        icon="arrow-left"
        style={{ position: "absolute", left: "8px", top: "45%" }}
        onClick={() => set_selected_backstory(prev_backstory)} />
      <Button
        fontSize="18px"
        icon="arrow-right"
        iconPosition="right"
        style={{ position: "absolute", right: "8px", top: "45%" }}
        onClick={() => set_selected_backstory(next_backstory)} />
    </Dimmer>
  );
};
