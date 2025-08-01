import { isEscape, KEY } from 'common/keys';
import { clamp } from 'common/math';
import { useEffect, useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, RestrictedInput, Section, Stack } from '../components';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type NumberInputData = {
  init_value: number;
  large_buttons: boolean;
  max_value: number | null;
  message: string;
  min_value: number | null;
  timeout: number;
  title: string;
  round_value: boolean;
};

export const NumberInputModal = (_) => {
  const { act, data } = useBackend<NumberInputData>();
  const {
    init_value,
    large_buttons,
    message = '',
    timeout,
    title,
    min_value,
    max_value,
  } = data;
  const [input, setInput] = useState(init_value);

  const [clampedInput, setClampedInput] = useState(
    clamp(input, min_value, max_value),
  );
  const setValue = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };

  useEffect(() => {
    setClampedInput(clamp(input, min_value, max_value));
  }, [input]);

  // Dynamically changes the window height based on the message.
  const windowHeight =
    140 +
    (message.length > 30 ? Math.ceil(message.length / 3) : 0) +
    (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={270} height={windowHeight} theme="generic">
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          if (event.key === KEY.Enter) {
            act('submit', { entry: clampedInput });
          }
          if (isEscape(event.key)) {
            act('cancel');
          }
        }}
      >
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea input={input} onClick={setValue} onChange={setValue} />
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={clampedInput} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props) => {
  const { act, data } = useBackend<NumberInputData>();
  const { min_value, max_value, init_value, round_value } = data;
  const { input, onClick, onChange } = props;
  const [inputValue, setInputValue] = useState(input);
  useEffect(() => {
    onChange(clamp(inputValue, min_value, max_value));
  }, [inputValue]);

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          disabled={input === min_value}
          icon="angle-double-left"
          onClick={() => {
            const newValue = min_value ?? 0; // Ensure a valid number
            setInputValue(newValue); // Update the input state
          }}
          tooltip={min_value ? `Min (${min_value})` : 'Min'}
        />
      </Stack.Item>
      <Stack.Item grow>
        <RestrictedInput
          autoFocus
          autoSelect
          fluid
          allowFloats={!round_value}
          minValue={min_value}
          maxValue={max_value}
          onChange={(_, value) => {
            setInputValue(value); // Update the input state when the user types
          }}
          onEnter={(_, value) => act('submit', { entry: value })}
          value={inputValue} // Ensure the input field reflects the current state
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === max_value}
          icon="angle-double-right"
          onClick={() => {
            const newValue = max_value ?? 0; // Ensure a valid number
            setInputValue(newValue); // Update the input state
          }}
          tooltip={max_value ? `Max (${max_value})` : 'Max'}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === init_value}
          icon="redo"
          onClick={() => {
            const newValue = init_value; // Reset to the initial value
            setInputValue(newValue); // Update the input state
          }}
          tooltip={init_value ? `Reset (${init_value})` : 'Reset'}
        />
      </Stack.Item>
    </Stack>
  );
};
