import { Button, Dropdown, Input, LabeledList, Section } from '../components';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  name: string;
  on: BooleanLike;
  say_verb: string;
  selected: string;
  voices: string[];
};

export const AiVoiceChanger = (props) => {
  const { act, data } = useBackend<Data>();
  const { name, on, say_verb, voices, selected } = data;

  return (
    <Window title="Voice changer settings" width={400} height={200}>
      <Section fill>
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button icon={on ? 'power-off' : 'times'} onClick={() => act('power')}>
              {on ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Accent">
            <Dropdown
              options={voices}
              onSelected={(value) => {
                act('look', {
                  look: value,
                });
              }}
              selected={selected}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Verb">
            <Input
              value={say_verb}
              onChange={(e, value) =>
                act('verb', {
                  verb: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Fake name">
            <Input
              value={name}
              onChange={(e, value) =>
                act('name', {
                  name: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
};
