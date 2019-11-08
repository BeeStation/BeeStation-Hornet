import { map } from 'common/fp';
import { toFixed } from 'common/math';
import { act } from '../byond';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';

const CHANNELS = [
  {
    name: 'Syndicate',
    freq: 1213,
    color: '#a52a2a',
  },
  {
    name: 'Red Team',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Blue Team',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'CentCom',
    freq: 1337,
    color: '#2681a5',
  },
  {
    name: 'Supply',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Service',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Science',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Command',
    freq: 1353,
    color: '#5177ff',
  },
  {
    name: 'Medical',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Security',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'AI Private',
    freq: 1447,
    color: '#d65d95',
  },
  {
    name: 'Common',
    freq: 1459,
    color: '#1ecc43',
  },
];

export const Radio = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
  } = data;
  const tunedChannel = CHANNELS
    .find(channel => channel.freq === frequency);
  const channels = map((value, key) => ({
    name: key,
    status: !!value,
  }))(data.channels);
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Frequency">
          {freqlock && (
            <Box inline color="light-gray">
              {toFixed(frequency / 10, 1) + ' kHz'}
            </Box>
          ) || (
            <NumberInput
              animate
              unit="kHz"
              step={0.2}
              stepPixelSize={10}
              minValue={minFrequency / 10}
              maxValue={maxFrequency / 10}
              value={frequency / 10}
              format={value => toFixed(value, 1)}
              onDrag={(e, value) => act(ref, 'frequency', {
                adjust: (value - frequency / 10),
              })} />
          )}
          {tunedChannel && (
            <Box inline color={tunedChannel.color} ml={2}>
              [{tunedChannel.name}]
            </Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Audio">
          <Button
            textAlign="center"
            width="37px"
            icon={listening ? 'volume-up' : 'volume-mute'}
            selected={listening}
            onClick={() => act(ref, 'listen')} />
          <Button
            textAlign="center"
            width="37px"
            icon={broadcasting ? 'microphone' : 'microphone-slash'}
            selected={broadcasting}
            onClick={() => act(ref, 'broadcast')} />
          {!!command && (
            <Button
              ml={1}
              icon="bullhorn"
              selected={useCommand}
              content={`High volume ${useCommand ? 'ON' : 'OFF'}`}
              onClick={() => act(ref, 'command')} />
          )}
          {!!subspaceSwitchable && (
            <Button
              ml={1}
              icon="bullhorn"
              selected={subspace}
              content={`Subspace Tx ${subspace ? 'ON' : 'OFF'}`}
              onClick={() => act(ref, 'subspace')} />
          )}
        </LabeledList.Item>
        {!!subspace && (
          <LabeledList.Item label="Channels">
            {channels.length === 0 && (
              <Box inline color="bad">
                No encryption keys installed.
              </Box>
            )}
            {channels.map(channel => (
              <Box key={channel.name}>
                <Button
                  icon={channel.status ? 'check-square-o' : 'square-o'}
                  selected={channel.status}
                  content={channel.name}
                  onClick={() => act(ref, 'channel', {
                    channel: channel.name,
                  })} />
              </Box>
            ))}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
