import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Section, Input, Button, Stack, Box } from '../components';
import { Window } from '../layouts';

type TGUITemplateData = {
  options: string[];
  ui_message: string;
  current_option: string;
  something_static: string;
};

export const TGUITemplate = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { options, ui_message, current_option, something_static } = data; // not used in this section, but remained here to remind

  return (
    <Window width={400} height={400} title="TGUI Template">
      <Window.Content>
        <MessageShower />
        <ButtonClicker />
        <ShowsStaticData />
        <ShowsAssetImage />
      </Window.Content>
    </Window>
  );
};

const MessageShower = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { ui_message } = data;

  return (
    <Section title="Message Shower">
      <Input
        align="right"
        value={ui_message}
        onChange={(e, value) => {
          act('change_message', { 'new_message': value });
        }}
      />
    </Section>
  );
};

const ButtonClicker = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { options } = data;

  return (
    <Section title="Button clicker">
      <Stack vertical>
        <Stack.Item>
          {'Buttons: '}
          {options.map((each) => {
            return <ButtonForChange key={each} chosen_option={each} />;
          })}
        </Stack.Item>
        <Stack.Item>
          {'Buttons as index: '}
          {Object.keys(options).map((each) => {
            return (
              <ButtonForChange key={each} chosen_option={options[each]} button_content={options[each] + ', idx ' + each} />
            );
          })}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ButtonClickerLocalState = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { options } = data;

  return (
    <Section title="Button clicker">
      This is the same code above, but it uses LocalState instead of saving it to DM side. This is faster than sending data to
      DM then updating.
      <Stack vertical>
        <Stack.Item>
          {'Buttons: '}
          {options.map((each_item, each_index) => {
            return <ButtonForChange key={each_item} chosen_option={each_item} />;
          })}
        </Stack.Item>
        <Stack.Item>
          {'Buttons as index: '}
          {Object.keys(options).map((each_index) => {
            return (
              <ButtonForChange
                key={each_index}
                chosen_option={options[each_index]}
                button_content={options[each_index] + ', idx ' + each_index}
              />
            );
          })}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ButtonForChange = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { chosen_option, button_content = null } = props;
  const [chosenOption, setChosenOption] = useLocalState(context, 'tgui_template_chosen_option', chosen_option);

  return (
    <Button
      key={chosen_option}
      disabled={chosen_option === chosenOption}
      onClick={() => act('button_clicked', { 'chosen_option': chosen_option })}>
      {button_content ? button_content : chosen_option}
    </Button>
  );
};

const ShowsStaticData = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { something_static } = data;

  return <Section title="Static data">{'Static string: ' + something_static}</Section>;
};

const ShowsAssetImage = () => {
  return (
    <Section title="Sprite asset sample">
      {'Asset image sample '}
      <Box className={classes(['design32x32', 'analyzer'])} />
    </Section>
  );
};
