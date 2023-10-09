import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Input, Button, Stack, Box } from '../components';
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
        <Stack vertical>
          <MessageShower />
          <ButtonClicker />
          <ShowsStaticData />
          <ShowsAssetImage />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MessageShower = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { ui_message } = data;

  return (
    <Stack.Item>
      {'Current text: '}
      <Input
        align="right"
        value={ui_message}
        onChange={(e, value) => {
          act('change_message', { 'new_message': value });
        }}
      />
    </Stack.Item>
  );
};

const ButtonClicker = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { options } = data;

  return (
    <>
      <Stack.Item>
        {'Buttons: '}
        {options.map((each) => {
          return <ButtonForChange key={each} chosen_option={each} />;
        })}
      </Stack.Item>
      <Stack.Item>
        {'Buttons as index: '}
        {Object.keys(options).map((each) => {
          return <ButtonForChange key={each} chosen_option={options[each]} button_content={options[each] + ', idx ' + each} />;
        })}
      </Stack.Item>
    </>
  );
};

const ButtonForChange = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { key, chosen_option, button_content = null } = props;
  const { current_option } = data;

  return (
    <Button
      key={key}
      disabled={chosen_option === current_option}
      onClick={(e) => act('button_clicked', { 'chosen_option': chosen_option })}>
      {button_content ? button_content : chosen_option}
    </Button>
  );
};

const ShowsStaticData = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context);
  const { something_static } = data;

  return <Stack.Item>{'Static string: ' + something_static}</Stack.Item>;
};

const ShowsAssetImage = (props, context) => {
  // const { act, data } = useBackend<TGUITemplateData>(context); // no need

  return (
    <Stack.Item>
      {'Asset image sample '}
      <Box className={classes(['design32x32', 'analyzer'])} />
    </Stack.Item>
  );
};
