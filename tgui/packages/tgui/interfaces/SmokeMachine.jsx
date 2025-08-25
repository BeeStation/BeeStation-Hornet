import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SmokeMachine = (props) => {
  const { act, data } = useBackend();
  const {
    TankContents,
    isTankLoaded,
    TankCurrentVolume,
    TankMaxVolume,
    active,
    setting,
    maxSetting,
  } = data;
  return (
    <Window width={350} height={350}>
      <Window.Content>
        <Section
          title="Dispersal Tank"
          buttons={
            <Button
              icon={active ? 'power-off' : 'times'}
              selected={active}
              onClick={() => act('power')}
            >
              {active ? 'On' : 'Off'}
            </Button>
          }
        >
          <ProgressBar
            value={TankCurrentVolume / TankMaxVolume}
            ranges={{
              bad: [-Infinity, 0.3],
            }}
          >
            <AnimatedNumber initial={0} value={TankCurrentVolume || 0} />
            {' / ' + TankMaxVolume}
          </ProgressBar>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label="Range">
                {[1, 2, 3, 4, 5].map((amount) => (
                  <Button
                    disabled={maxSetting < amount}
                    icon="plus"
                    key={amount}
                    onClick={() => act('setting', { amount })}
                    selected={setting === amount}
                  >
                    {amount * 3}
                  </Button>
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
        <Section
          title="Contents"
          buttons={
            <Button icon="trash" onClick={() => act('purge')}>
              Purge
            </Button>
          }
        >
          {TankContents.map((chemical) => (
            <Box key={chemical.name} color="label">
              <AnimatedNumber initial={0} value={chemical.volume} /> units of{' '}
              {chemical.name}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
