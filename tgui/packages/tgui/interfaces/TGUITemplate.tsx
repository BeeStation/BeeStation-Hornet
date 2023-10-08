import { BooleanLike } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
import { Input, Button, Stack } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';
import { map } from 'common/collections';

type TGUITemplateData = {
  options: string[];
  ui_message: string;
  current_option: string;
};

export const TGUITemplate = (props, context) => {
  const { act, data } = useBackend<TGUITemplateData>(context); // not used in this section, but remained here
  const { options, ui_message, current_option } = data; // same above

  return (
    <Window width={400} height={400} title="TGUI Template">
      <Window.Content>
        <Stack vertical>
          <MessageShower />
          <ButtonClicker />
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
          act('change_message', { 'new_message': value, 'event_check': e });
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
        {'Buttons 1: '}
        {Object.keys(options).forEach((each) => {
          '/test: ' + each;
        })}
      </Stack.Item>
      <Stack.Item>
        {'Buttons 2: '}
        {Object.keys(options).map((each) => {
          '/test: ' + each;
        })}
      </Stack.Item>
      <Stack.Item>
        {'Buttons 3: '}
        {options.forEach((each) => {
          '/test: ' + each;
        })}
      </Stack.Item>
      <Stack.Item>
        {'Buttons 4: '}
        {options.map((each) => {
          '/test: ' + each;
        })}
      </Stack.Item>
      {'-----------------------------'}
      <Stack.Item />
      <Stack.Item>
        {'manual expression: '}
        {options[0]}
        {options[1]}
      </Stack.Item>
      <Stack.Item>{'values: ' + options}</Stack.Item>
      <Stack.Item>{'keys: ' + Object.keys(options)}</Stack.Item>
    </>
  );
};
