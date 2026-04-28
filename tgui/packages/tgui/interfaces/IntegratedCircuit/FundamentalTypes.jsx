import { Dropdown } from 'tgui-core/components';

import { Button, Input, NumberInput, Stack } from '../../components';
import { BasicInput } from './BasicInput';

export const FUNDAMENTAL_DATA_TYPES = {
  string: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput name={name} setValue={setValue} value={value} defaultValue="">
        <Input
          placeholder={name}
          value={value}
          onChange={(e, val) => setValue(val)}
          width="96px"
        />
      </BasicInput>
    );
  },
  number: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={0}
      >
        <NumberInput
          value={value}
          color={color}
          minValue={-Infinity}
          maxValue={Infinity}
          step={1}
          onChange={(val) => setValue(val)}
          unit={name}
        />
      </BasicInput>
    );
  },
  entity: (props) => {
    const { name, setValue } = props;
    return (
      <Button
        content={name}
        color="transparent"
        icon="upload"
        compact
        onClick={() => setValue(null, { marked_atom: true })}
      />
    );
  },
  signal: (props) => {
    const { name, setValue } = props;
    return (
      <Button
        content={name}
        color="transparent"
        compact
        onClick={() => setValue()}
      />
    );
  },
  option: (props) => {
    const { value, setValue, extraData } = props;
    return (
      <Dropdown
        className="Datatype__Option"
        color={'transparent'}
        options={Array.isArray(extraData) ? extraData : Object.keys(extraData)}
        onSelected={setValue}
        selected={value}
        noscroll
      />
    );
  },
  any: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={''}
      >
        <Stack>
          <Stack.Item>
            <Button
              color={color}
              icon="upload"
              onClick={() => setValue(null, { marked_atom: true })}
            />
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder={name}
              value={value}
              onChange={(e, val) => setValue(val)}
              width="64px"
            />
          </Stack.Item>
        </Stack>
      </BasicInput>
    );
  },
};

export const DATATYPE_DISPLAY_HANDLERS = {
  option: (port) => {
    return port.name.toLowerCase();
  },
};
