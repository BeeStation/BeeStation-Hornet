import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

export const Radio = (props) => {
  const { act, data } = useBackend();
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    enabled,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find((channel) => channel.freq === frequency);
  const channels = map(data.channels, (value, key) => ({
    name: key,
    status: !!value,
  }));
  return (
    <Window width={360} height={106 + (channels.len > 0 ? 6 + channels.len * 21 : 24)}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              {(freqlock && (
                <Box inline color="light-gray">
                  {toFixed(frequency / 10, 1) + ' kHz'}
                </Box>
              )) || (
                <NumberInput
                  animated
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={10}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={(value) => toFixed(value, 1)}
                  onDrag={(value) =>
                    act('frequency', {
                      adjust: value - frequency / 10,
                    })
                  }
                />
              )}
              {tunedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Audio">
              <Button textAlign="center" width="37px" icon={'power-off'} selected={enabled} onClick={() => act('enable')} />
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                onClick={() => act('broadcast')}
              />
              {!!command && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={useCommand}
                  content={`High volume ${useCommand ? 'ON' : 'OFF'}`}
                  onClick={() => act('command')}
                />
              )}
              {!!subspaceSwitchable && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={subspace}
                  content={`Subspace Tx ${subspace ? 'ON' : 'OFF'}`}
                  onClick={() => act('subspace')}
                />
              )}
            </LabeledList.Item>
            {!!subspace && (
              <LabeledList.Item label="Channels">
                {channels.length === 0 && (
                  <Box inline color="bad">
                    No encryption keys installed.
                  </Box>
                )}
                {channels.map((channel) => (
                  <Box key={channel.name}>
                    <Button
                      icon={channel.status ? 'check-square-o' : 'square-o'}
                      selected={channel.status}
                      content={channel.name}
                      onClick={() =>
                        act('channel', {
                          channel: channel.name,
                        })
                      }
                    />
                  </Box>
                ))}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
